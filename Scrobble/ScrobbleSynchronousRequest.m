//
//  ScrobbleSynchronousRequest.m
//  StalkWeb
//
//  Created by Carl Drinkwater on 27/06/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#import "ScrobbleSynchronousRequest.h"
#import "JSON.h"

@implementation ScrobbleSynchronousRequest

- (id)initWithURL:(NSURL *)url {
	id jsonData = nil;
	NSData *data;
	self = [super init];
	
	if ( self ) {
		NSURLResponse *returningResponse;
		NSError *error;

		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
		[request setValue:@"StalkFM v0.1" forHTTPHeaderField:@"User-Agent"];
		
		// TODO: error-checking.
		NSLog( @"Making synchronous request" );
		data = [NSURLConnection sendSynchronousRequest:request returningResponse:&returningResponse error:&error];

		NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog( @"Done with synchronous request", str );
		
		jsonData = [str JSONValue];
	}
	
	return jsonData;
}

@end
