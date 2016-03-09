//
//  PublishOptions.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "PublishOptions.h"
#import "DEBUG.h"


@implementation PublishOptions

-(id)init {
	
    if ( (self=[super init]) ) {
        _publisherId = nil;
#if _MUTABLE_HEADERS_
        _headers = nil;
#else
        self.headers = @{@"ios-content-available":@"1"};
#endif
        _subtopic = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PublishOptions"];
    
    [_publisherId release];
    [_headers release];
    [_subtopic release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

#if _MUTABLE_HEADERS_
-(BOOL)addHeader:(NSString *)key value:(NSString *)value {
    
    if (!key || !value) {
        return NO;
    }
    
    if (!_headers) {
        _headers = [NSMutableDictionary new];
    }
    [_headers setValue:value forKey:key];
    
    return YES;
}
#else
-(BOOL)addHeader:(NSString *)key value:(NSString *)value {
    
    if (!key || !value) {
        return NO;
    }
    
    NSMutableDictionary *dict = _headers ? [[NSMutableDictionary alloc] initWithDictionary:_headers] : [NSMutableDictionary new];
    [dict setValue:value forKey:key];
    [_headers release];
    self.headers = dict;
    
    return YES;
}
#endif
-(NSString *)description {
    return [NSString stringWithFormat:@"<PublishOptions> publisherId: %@, headers: %@, subtopic = %@", _publisherId, _headers, _subtopic];
}

@end
