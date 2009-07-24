//
//  ScrobbleTrack.m
//  StalkWeb
//
//  Created by Carl Drinkwater on 24/06/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import "ScrobbleTrack.h"


@implementation ScrobbleTrack

- (ScrobbleTrack *)initWithSongName:(NSString *)theSongName artistName:(NSString *)theArtistName {
	self = [super init];
	
	if ( self ) {
		songName = [[theSongName copy] retain];
		artistName = [[theArtistName copy] retain];
	}
	
	return self;
}

- (NSString *)songName {
	return songName;
}

- (NSString *)artistName {
	return artistName;
}

- (BOOL)equalToTrack:(ScrobbleTrack *)otherTrack {
	if ( [songName isEqualToString:[otherTrack songName]] &&
	     [artistName isEqualToString:[otherTrack artistName]] ) {
		return true;
	}
	
	return false;
}

- (void)dealloc {
	[songName release];
	[artistName release];

	[super dealloc];
}

@end
