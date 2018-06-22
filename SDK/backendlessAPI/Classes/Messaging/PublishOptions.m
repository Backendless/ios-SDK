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
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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

@interface PublishOptions()

@property (strong, nonatomic) NSMutableDictionary *headers;

@end

@implementation PublishOptions

-(id)init {
    if (self = [super init]) {
        _publisherId = nil;
        _subtopic = nil;
        [self defaultHeaders];
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

-(void)defaultHeaders {
    self.headers = [NSMutableDictionary dictionaryWithDictionary:@{@"ios-content-available":@"1"}];
}

-(BOOL)addHeader:(NSString *)key value:(id)value {
    if (!key || !value) {
        return NO;
    }
    [_headers setValue:value forKey:key];
    return YES;
}

-(BOOL)removeHeader:(NSString *)key {
    if (!key) {
        return NO;
    }
    [_headers removeObjectForKey:key];
    return YES;
}

-(void)assignHeaders:(NSDictionary *)headers {    
    if (headers) {
        self.headers = [NSMutableDictionary dictionaryWithDictionary:headers];
    }
    else {
        [self defaultHeaders];        
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<PublishOptions> publisherId: %@, headers: %@, subtopic = %@", _publisherId, _headers, _subtopic];
}

@end
