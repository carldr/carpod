//
//  ScrobbleRequest.h
//  StalkWeb
//
//  Created by Carl Drinkwater on 27/06/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ScrobbleRequest : NSObject {
	NSMutableURLRequest *_request;
	NSURLConnection *_connection;
	NSMutableData *_data;
	
	id _callbackObject;
	SEL _callbackSelector;
}

- (ScrobbleRequest *)initWithURL:(NSURL *)url callbackObject:(id)theObject callbackSelector:(SEL)theSelector;

@end
