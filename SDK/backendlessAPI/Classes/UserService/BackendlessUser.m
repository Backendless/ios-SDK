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

@interface BackendlessUser () {
    HashMap *properties;
}

@end


@implementation BackendlessUser

-(id)init {
	if ( (self=[super init]) ) {
        properties = nil;
	}
	
	return self;
}

-(id)initWithProperties:(NSDictionary *)props {
	if ( (self=[super init]) ) {
        properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessUser "];
    
    [properties release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark getters / setters

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

-(NSString *)getUserId {
    return [self getProperty:BACKENDLESS_ID_KEY];
}

-(NSString *)getUserToken {
    return [self getProperty:BACKENDLESS_USER_TOKEN];
}

#pragma mark -
#pragma mark Public Methods

-(void)setProperties:(NSDictionary *)props {
    if (properties) {
        NSArray *keys = [props allKeys];
        for (NSString *key in keys) {
            [properties push:key withObject:props[key]];
        }
    }
    else
    {
        properties = (props) ? [[HashMap alloc] initWithNode:props] : nil;
    }
}

-(NSDictionary *)getProperties {
    return (properties) ? properties.node : nil;
}

-(void)updateProperties:(NSDictionary *)props {
    
    NSArray *names = [props allKeys];
    for (NSString *name in names)
        [self setProperty:name object:[props objectForKey:name]];
}

-(id)getProperty:(NSString *)key {
    return (properties) ? [properties get:key] : nil;
}

-(void)setProperty:(NSString *)key object:(id)value {
    
    if (!properties)
        properties = [HashMap new];
    
    [properties push:key withObject:value];
}

-(void)removeProperty:(NSString *)key {
    
    if (!properties)
        return;
    
    [properties del:key];
}
-(void)setObjectId:(NSString *)objectId
{
    [self setProperty:@"objectId" object:objectId];
}
-(NSString *)objectId
{
    return [self getProperty:@"objectId"];
}
-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessUser> email:'%@', password:'%@', name:'%@', userId:'%@', userToken:'%@', objectId:'%@', properties:%@", self.email, self.password, self.name, self.userId, self.userToken, self.objectId, properties.node];
}

@end
