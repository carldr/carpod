//
//  ScrobbleTrack.h
//  StalkWeb
//
//  Created by Carl Drinkwater on 24/06/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScrobbleTrack : NSObject {
	NSString *songName;
	NSString *artistName;
}

- (ScrobbleTrack *)initWithSongName:(NSString *)theSongName artistName:(NSString *)theArtistName;

- (BOOL)equalToTrack:(ScrobbleTrack *)otherTrack;

- (NSString *)songName;
- (NSString *)artistName;

@end
