//
//  ScrobbleRequest.m
//  StalkWeb
//
//  Created by Carl Drinkwater on 27/06/2009.
//  Copyright 2009 Carl Drinkwater. All rights reserved.
//

#import "ScrobbleRequest.h"
#import "JSON.h"

@implementation ScrobbleRequest

- (ScrobbleRequest *)initWithURL:(NSURL *)url callbackObject:(id)theObject callbackSelector:(SEL)theSelector {
	self = [super init];
	
	if ( self ) {
		_request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0];
		[_request setValue:@"StalkFM v0.1" forHTTPHeaderField:@"User-Agent"];

		_callbackObject = [theObject retain];
		_callbackSelector = theSelector;
		_data = [[NSMutableData alloc] init];
		
		// TODO: Making sure we sleep for a second between requests.

		_connection = [NSURLConnection connectionWithRequest:_request delegate:self];	
	}
	
	return self;
}

- (void)dealloc {
	[_connection cancel];
	[_connection release];

	[_data release];
	[_callbackObject release];
	[_request release];

	[super dealloc];
}


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)theResponse {
	[_data setLength:0];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)theData {
	[_data appendData:theData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *str = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
	id obj = [str JSONValue];

	[_callbackObject performSelector:_callbackSelector withObject:obj];
	
	[str release];
}

@end
