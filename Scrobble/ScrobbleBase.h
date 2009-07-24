//
//  ScrobbleBase.h
//  StalkWeb
//
//  Created by Carl Drinkwater on 24/06/2009.
//  Copyright 2009 Carl Drinkwater. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrobbleRequest.h"

@interface ScrobbleBase : NSObject {
}

- (ScrobbleRequest *)makeRequestToService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication callbackObject:(id)theObject callbackSelector:(SEL)theSelector;
- (id)makeSynchronousRequestToService:(NSString *)theService params:(NSDictionary *)theParams withAuthentication:(BOOL)requiresAuthentication;

@end
