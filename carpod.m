//
//  carpod.m
//  carpod
//
//  Created by Carl Drinkwater on 24/07/2009.
//  Copyright 2009 Carl Drinkwater. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EyeTunes/EyeTunes.h>
#import "JSON/JSON.h"
#import "ScrobbleBase.h"
#import "carpod.h"

// Globals
EyeTunes *eyetunes = NULL;
NSAutoreleasePool *pool = NULL;
ScrobbleBase *scrobbleBase = NULL;

// Method declarations
void init();
void cleanup();
NSArray *get_playlists();
NSArray *get_albums( const char *username );
BOOL tie_em_up( NSArray *playlists, NSArray *albums );
NSInteger trackSort( id num1, id num2, void *context );

// This is where is all starts.  The value we return here is what is returned as the app's return code.
int run( const char *username ) {
	init();

	eyetunes = [EyeTunes sharedInstance];
	if ( !eyetunes ) {
		printf( "Couldn't get iTunes shared instance.\n" );
		cleanup();
		return EXIT_ERROR;
	}
	
	NSArray *ourPlaylists = get_playlists();
	if ( !ourPlaylists ) {
		cleanup();
		return EXIT_ERROR;
	}

	NSArray *ourAlbums = get_albums( username );
	if ( !ourAlbums ) {
		cleanup();
		return EXIT_ERROR;
	}
	
	if ( !tie_em_up( ourPlaylists, ourAlbums ) ) {
		cleanup();
		return EXIT_ERROR;
	}

	printf( "It all worked!  Now make sure playlists 1-5 sync with your iPod, then actually sync them!\n" );
	
	cleanup();
	return EXIT_OK;
}

// Rest of the methods
void init() {
	pool = [[NSAutoreleasePool alloc] init];
	scrobbleBase = [[ScrobbleBase alloc] init];
}

void cleanup() {
	[pool release];
	[scrobbleBase release];
}


//  Returns an array of playlists, with playlist 1 in index 0, playlist 2 in index 1 etc.
NSArray *get_playlists() {
	NSMutableArray *ourPlaylists = [[NSMutableArray alloc] init];
	
	ETPlaylist *libraryPlaylist = [eyetunes libraryPlaylist];
	if ( !libraryPlaylist ) {
		printf( "Couldn't find library playlist.  Is iTunes running?\n" );
		return nil;
	}
	
	for ( int i=1; i<=5; i++ ) {
		ETPlaylist *foundPlaylist = nil;

		for ( ETPlaylist *playlist in [eyetunes playlists] ) {
			if ( [[NSString stringWithFormat:@"--- %d", i] isEqualToString:[playlist name]] ) {
				foundPlaylist = playlist;
				
				break;
			}
		}
		
		if ( foundPlaylist ) {
			[ourPlaylists addObject:foundPlaylist];

			// Remove any tracks which are currently in the playlist.
			NSAppleScript *emptyPlaylist;
			NSDictionary *error = nil;
			
			NSString *emptyPlaylistString = [NSString stringWithFormat:@"tell application \"iTunes\"\ndelete every track of playlist \"--- %d\"\nend tell", i];
			emptyPlaylist = [[NSAppleScript alloc] initWithSource:emptyPlaylistString];
			
			if (![emptyPlaylist executeAndReturnError:&error]) {
				printf( "Couldn't ensure that playlist '--- %d' is empty.  Error: %s", i, [[error objectForKey:@"NSAppleScriptErrorMessage"] cStringUsingEncoding:NSUTF8StringEncoding] );
				return NO;
			}
			
			continue;
		}
			
		printf( "Playlist %d not found.  Creating.\n", i );
		
		NSAppleScript *createPlaylist;
		NSDictionary *error = nil;

		NSString *createPlaylistString = [NSString stringWithFormat:@"tell application \"iTunes\"\nset aPlaylist to make new playlist with properties {name:\"--- %d\"}\nend tell", i ];
		createPlaylist = [[NSAppleScript alloc] initWithSource:createPlaylistString];

		if (![createPlaylist executeAndReturnError:&error]) {
			printf( "Couldn't create playlist '--- %d'.  Error: %s", i, [[error objectForKey:@"NSAppleScriptErrorMessage"] cStringUsingEncoding:NSUTF8StringEncoding] );
			return NO;
		}
		
		for ( ETPlaylist *playlist in [eyetunes playlists] ) {
			if ( [[NSString stringWithFormat:@"--- %d", i] isEqualToString:[playlist name]] ) {
				foundPlaylist = playlist;
				
				break;
			}
		}
		
		if ( !foundPlaylist ) {
			printf( "Couldn't find newly create playlist '--- %d'.\n", i );
			return nil;
		}

		[ourPlaylists addObject:foundPlaylist];
	}
	
	return ourPlaylists;
}

//  Returns an array of up to the five most played albums in the past 3 months
NSArray *get_albums( const char *username ) {
	int count = 0;
	NSMutableArray *ourAlbums = [[NSMutableArray alloc] init];

	NSDictionary *albums =  [scrobbleBase makeSynchronousRequestToService:@"user.getTopAlbums"
																   params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithCString:username], @"user", @"3month", @"period", nil]
                                                       withAuthentication:NO];
	
	for ( NSDictionary *album in [[albums objectForKey:@"topalbums"] objectForKey:@"album"] ) {
		NSString *albumName = [album objectForKey:@"name"];
		NSString *artistName = [[album objectForKey:@"artist"] objectForKey:@"name"];

		[ourAlbums addObject:[NSDictionary dictionaryWithObjectsAndKeys:albumName, @"album", artistName, @"artist", nil]];
		if ( ++count == 5 ) {
			return ourAlbums;
		}
	}

	return ourAlbums;
}

BOOL tie_em_up( NSArray *playlists, NSArray *albums ) {
	ETPlaylist *musicPlaylist = nil;
	
	for ( musicPlaylist in [eyetunes playlists] ) {
		if ( [[musicPlaylist name] isEqualToString:@"Music"] ) {
			break;
		}
	}
	
	if ( !musicPlaylist ) {
		printf( "Couldn't find Music playlist.  Is iTunes running?\n" );

		return NO;
	}
	
	for( int i=0; i<[albums count]; i++ ) {
		NSNumber *number = [NSNumber numberWithInt:i+1];
		NSAppleScript *addToPlaylist;
		NSDictionary *error = nil;
		
		NSString *addToPlaylistString = [NSString stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\")) to playlist \"--- %@\"\nend tell", [[albums objectAtIndex:i] objectForKey:@"artist"], [[albums objectAtIndex:i] objectForKey:@"album"], [number stringValue] ];
		addToPlaylist = [[NSAppleScript alloc] initWithSource:addToPlaylistString];
		
		if (![addToPlaylist executeAndReturnError:&error]) {
			printf( "Couldn't add tracks from '%s' by %s to playlist '--- %d'.  Error: %s", [[[albums objectAtIndex:i] objectForKey:@"album"] cStringUsingEncoding:NSUTF8StringEncoding],
				                                                                            [[[albums objectAtIndex:i] objectForKey:@"artist"] cStringUsingEncoding:NSUTF8StringEncoding],
																					        i,
																					        [[error objectForKey:@"NSAppleScriptErrorMessage"] cStringUsingEncoding:NSUTF8StringEncoding] );
			return NO;
		}
	}
	
	return YES;
}

NSInteger trackSort( id num1, id num2, void *context ) {
	if ( [num1 trackNumber] < [num2 trackNumber] ) {
		return NSOrderedAscending;
		
	} else if ( [num1 trackNumber] > [num2 trackNumber] ) {
		return NSOrderedDescending;

	}
	
	return NSOrderedSame;
}