//
//  BackendlessUser.m
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

#import "BackendlessUser.h"
#import "Backendless.h"
#import "HashMap.h"

@interface BackendlessUser() {
    HashMap *__properties;
}
@end

@implementation BackendlessUser

-(id)init {
    if (self=[super init]) {
        __properties = nil;
    }
    return self;
}

-(id)initWithProperties:(NSDictionary<NSString*, id> *)props {
    if (self=[super init]) {
        __properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC BackendlessUser "];
    [__properties release];
    [super dealloc];
}

-(NSString *)getObjectId {
    return [self getProperty:PERSIST_OBJECT_ID];
}

-(void)setObjectId:(NSString *)objectId {
    [self setProperty:PERSIST_OBJECT_ID object:objectId];
}

-(NSString *)getEmail {
    return [self getProperty:BACKENDLESS_EMAIL_KEY];
}

-(void)setEmail:(NSString *)emailAddress {
    [self setProperty:BACKENDLESS_EMAIL_KEY object:emailAddress];
}

-(NSString *)getPassword {
    return [self getProperty:BACKENDLESS_PASSWORD_KEY];
}

-(void)setPassword:(NSString *)password {
    [self setProperty:BACKENDLESS_PASSWORD_KEY object:password];
}

-(NSString *)getName {
    return [self getProperty:BACKENDLESS_NAME_KEY];
}

-(void)setName:(NSString *)name {
    [self setProperty:BACKENDLESS_NAME_KEY object:name];
}

-(BOOL)isUserRegistered {
    return [[self getProperty:BACKENDLESS_USER_REGISTERED] isKindOfClass:NSNumber.class];
}

-(NSString *)getUserToken {
    NSString *token = [self getProperty:BACKENDLESS_USER_TOKEN];
    if (token)
        return token;
    BackendlessUser *currentUser = backendless.userService.currentUser;
    if (currentUser && self.objectId == currentUser.objectId) {
        return [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
    }
    return nil;
}

-(void)assignProperties:(NSDictionary<NSString*, id> *)props {
    [__properties release];
    __properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
}

-(void)setProperties:(NSDictionary<NSString*, id> *)props {
    [__properties release];
    __properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
}

-(void)addProperties:(NSDictionary<NSString*, id> *)props {
    if (__properties) {
        NSArray *keys = [props allKeys];
        for (NSString *key in keys) {
            [__properties add:key withObject:props[key]];
        }
    }
    else {
        __properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
    }
}

-(NSDictionary<NSString*, id> *)retrieveProperties {
    return (__properties) ? [NSDictionary dictionaryWithDictionary:__properties.node] : [NSDictionary dictionary];
}

-(NSDictionary<NSString *, id> *)getProperties {
    return (__properties) ? [NSDictionary dictionaryWithDictionary:__properties.node] : [NSDictionary dictionary];
}

-(void)updateProperties:(NSDictionary<NSString*, id> *)props {
    
    NSArray *names = [props allKeys];
    for (NSString *name in names)
        [self setProperty:name object:[props objectForKey:name]];
}

-(id)getProperty:(NSString *)key {
    if (!__properties || [[__properties get:key] isKindOfClass:[NSNull class]])
        return nil;
    else
        return [__properties get:key];
}

-(void)setProperty:(NSString *)key object:(id)value {
    if (!__properties)
        __properties = [HashMap new];
    [__properties push:key withObject:value];
}

-(void)removeProperty:(NSString *)key {
    if (!__properties)
        return;
    if ([__properties get:key]) {
        [__properties push:key withObject:nil];
    }
}

-(void)removeProperties:(NSArray<NSString*> *)keys {
    if (!__properties)
        return;
    for (NSString *key in keys) {
        if ([__properties get:key]) {
            [__properties push:key withObject:nil];
        }
    }
}

-(void)persistCurrentUser {
    if (backendless.userService.isStayLoggedIn && backendless.userService.currentUser && [self.objectId isEqualToString:backendless.userService.currentUser.objectId]) {
        [backendless.userService setPersistentUser];
    }
}

-(id)copyWithZone:(NSZone *)zone {
    return [[BackendlessUser alloc] initWithProperties:[self getProperties]];
}

@end
