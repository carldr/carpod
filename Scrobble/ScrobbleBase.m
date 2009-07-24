//
//  ScrobbleBase.m
//  StalkWeb
//
//  Created by Carl Drinkwater on 24/06/2009.
//  Copyright 2009 29degrees Limited. All rights reserved.
//

#include <openssl/md5.h>
#import "ScrobbleBase.h"
#import "ScrobbleRequest.h"
#import "ScrobbleSynchronousRequest.h"

@implementation ScrobbleBase

NSString *LAST_FM_API_KEY = @"8252ee20d19e64284ff60c8e952eee4f";  // TODO: #define?

- (NSString *)urlEncode:(NSString *)param {
	NSString *result = [param stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return result;
}

- (NSString *)md5HashForString:(NSString *)theString {
	NSData *data = [theString dataUsingEncoding:NSUTF8StringEncoding];

	unsigned char *digest = MD5( [data bytes], [data length], NULL );
	if ( digest ) {
		NSMutableString *ms = [NSMutableString string];
		
		for ( int i=0; i < MD5_DIGEST_LENGTH; i++ ) {
			[ms appendFormat:@"%02x", (int)digest[i]];
		}

		return [[ms copy] autorelease];
	}
	
	// TODO: Error

	return nil;
}

- (NSString *)buildMethodSignature:(NSDictionary *)theParams {
	NSMutableString *methodSignature = [NSMutableString stringWithString:@""];
	
	for ( NSString *param in [[theParams allKeys] sortedArrayUsingSelector:@selector(compare:)] ) {
		[methodSignature appendString:param];
		[methodSignature appendString:[theParams objectForKey:param]];
	}
	
	return [self md5HashForString:methodSignature];
}

- (NSURL *)buildURLForService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication {
	NSMutableString *url = [NSMutableString stringWithString:@"http://ws.audioscrobbler.com/2.0/?"];
	NSMutableDictionary *paramsToSend;	
	
	paramsToSend = [NSMutableDictionary dictionaryWithObject:theService forKey:@"method"];
	[paramsToSend setObject:LAST_FM_API_KEY forKey:@"api_key"];
	
	if ( theParams ) {
		[paramsToSend addEntriesFromDictionary:theParams];
	}
	
	if ( requiresAuthentication ) {
		// REMOVED FROM VERSION DISTRIBUTED WITH CARPOD
	}

	[paramsToSend setObject:[self buildMethodSignature:paramsToSend] forKey:@"api_sig"];
	[paramsToSend setObject:@"json" forKey:@"format"]; // We prefer JSON.

	// URL-encode the parameters
	NSMutableArray *paramsArray = [[NSMutableArray alloc] init];
	for ( NSString *param in paramsToSend ) {
		NSMutableString *keyValue = [NSMutableString stringWithString:@""];
		
		[keyValue appendString:param];
		[keyValue appendString:@"="];
		[keyValue appendString:[self urlEncode:[paramsToSend objectForKey:param]]];
		
		[paramsArray addObject:keyValue];
	}
	

	// Build the URL
	[url appendString:[paramsArray componentsJoinedByString:@"&"]];
	
	return [NSURL URLWithString:url];
}

- (ScrobbleRequest *)makeRequestToService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication callbackObject:(id)theObject callbackSelector:(SEL)theSelector {
	NSURL *url = [self buildURLForService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication];

	// TODO:  Handle errors in the callback.
	if ( !url ) {
		return nil;
	}
	
	return [[ScrobbleRequest alloc] initWithURL:url callbackObject:theObject callbackSelector:theSelector];
}

- (id)makeSynchronousRequestToService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication {
	NSURL *url = [self buildURLForService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication];

	// TODO:  Handle errors in the callback.
	if ( !url ) {
		return nil;
	}

	return [[ScrobbleSynchronousRequest alloc] initWithURL:url];
}

@end
