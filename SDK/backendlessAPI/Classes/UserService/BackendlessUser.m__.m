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


@implementation BackendlessUser

-(id)initWithProperties:(NSDictionary<NSString*, id> *)props {
	if ( (self=[super init]) ) {
        [self resolveProperties:props];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessUser "];
	
	[super dealloc];
}

#pragma mark -
#pragma mark getters / setters

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

#pragma mark -
#pragma mark Public Methods

-(NSString *)getUserToken {
    return [self getProperty:BACKENDLESS_USER_TOKEN];
}

-(void)assignProperties:(NSDictionary<NSString*, id> *)props {
    [self replaceAllProperties];
    [self resolveProperties:props];
}

-(void)addProperties:(NSDictionary<NSString*, id> *)props {
    [self resolveProperties:props];
}

-(NSDictionary<NSString*, id> *)retrieveProperties {
    return [Types propertyDictionary:self];
}

-(void)updateProperties:(NSDictionary<NSString*, id> *)props {
    
    NSArray *names = [props allKeys];
    for (NSString *name in names)
        [self setProperty:name object:[props objectForKey:name]];
}

//-(BOOL)getPropertyIfResolved:(NSString *)name value:(id *)value;

-(id)getProperty:(NSString *)key {
    id obj = nil;
    return [self getPropertyIfResolved:key value:&obj] ? obj : nil;
}

// -(BOOL)resolveProperty:(NSString *)name value:(id)value;
-(void)setProperty:(NSString *)key object:(id)value {
    [self resolveProperty:key value:value];
    
    if (backendless.userService.isStayLoggedIn && backendless.userService.currentUser && [self.objectId isEqualToString:backendless.userService.currentUser.objectId]) {
        [backendless.userService setPersistentUser];
    }
}

-(void)removeProperty:(NSString *)key {
    [self replaceProperty:key];
}

-(void)removeProperties:(NSArray<NSString*> *)keys {
    [self replaceProperties:keys];
}

#pragma mark -
#pragma mark overwrided NSObject Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessUser [%@]> %@", [super description], [self retrieveProperties]];
}

@end
