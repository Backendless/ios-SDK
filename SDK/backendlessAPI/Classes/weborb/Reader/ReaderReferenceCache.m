//
//  ReaderReferenceCache.h
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

#import "ReaderReferenceCache.h"
#import "DEBUG.h"
#import "Types.h"
#import "ITypeReader.h"

#define _OLD_ 0

@implementation ReaderReferenceCache

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(ReaderReferenceCache *)sharedInstance {
    static ReaderReferenceCache *sharedReaderReferenceCache;
    @synchronized(self)
    {
        if (!sharedReaderReferenceCache)
            sharedReaderReferenceCache = [ReaderReferenceCache new];
    }
    return sharedReaderReferenceCache;
}

-(id)init {	
	if ( (self=[super init]) ) {
		cache = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

+(id)cache {
#if _ReaderReferenceCache_IS_SINGLETON_
    return [ReaderReferenceCache sharedInstance];
#else
    return [[[ReaderReferenceCache alloc] init] autorelease];
#endif
}

-(void)dealloc {
	
    [DebLog logN:@"DEALLOC ReaderReferenceCache"];
	
	[cache removeAllObjects];
	[cache release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(NSString *)objectKey:(id <IAdaptingType>)key {
    return key?[NSString stringWithFormat:@"%lu", (unsigned long)[key hash]]:@"null";
}


#pragma mark -
#pragma mark Public Methods

-(BOOL)hasObject:(id <IAdaptingType>)key {
    return [self hasObject:key type:[key getDefaultType]];
}

-(BOOL)hasObject:(id <IAdaptingType>)key type:(Class)type {
    
    if (!key || !type) {
        return NO;
    }
    
    [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> hasObject: key=%@, type=%@", self, [self objectKey:key], type];
    
#if _OLD_
    NSDictionary *dict = [cache objectForObjectKey:key];
#else
    NSDictionary *dict = [cache valueForKey:[self objectKey:key]];
#endif
    if (!dict)
        return NO;
    
    if ([dict objectForClassKey:type])
        return YES;
    
    NSArray *keys = [dict allKeys];
    for (NSString *item in keys) {
        if ([[__types classByName:item] isSubclassOfClass:type])
            return YES;
    }
    
    return NO;
}

-(void)addObject:(id <IAdaptingType>)key object:(id)value {
    [self addObject:key type:[key getDefaultType] object:value];
}

-(void)addObject:(id <IAdaptingType>)key type:(Class)type object:(id)value {
    if (!key || !type) {
        return;
    }    
#if _OLD_
    NSMutableDictionary *dict = [cache objectForObjectKey:key];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [cache setObject:dict forObjectKey:key];
    }
#else
    NSString *_key = [self objectKey:key];
    NSMutableDictionary *dict = [cache valueForKey:_key];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [cache setObject:dict forKey:_key];
    }
#endif
    
    [dict setObject:value forClassKey:type];
    
    [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> addObject: (ADDED) key=%@, type=%@ [count=%d]", self, [self objectKey:key], type, dict.count];
}

-(id)getObject:(id <IAdaptingType>)key {
    return [self getObject:key type:[key getDefaultType]];
}

-(id)getObject:(id <IAdaptingType>)key type:(Class)type {
    
#if _OLD_
    NSDictionary *dict = [cache objectForObjectKey:key];
#else
    NSDictionary *dict = [cache valueForKey:[self objectKey:key]];
#endif
    if (!dict) {
        [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> getObject: (KEY DON'T EXIST) key=%@, type=%@", self, [self objectKey:key], type];
        return nil;
    }
    
    id obj = [dict objectForClassKey:type];
    if (obj) {
        [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> getObject: (CLASS EXISTED) key=%@, type=%@ [count=%d]\n%@", self, [self objectKey:key], type, dict.count, obj];
        return obj;
    }
    
    NSArray *keys = [dict allKeys];
    for (NSString *item in keys) {
        Class _class = [__types classByName:item];
        if ([_class isSubclassOfClass:type]) {
            obj = [dict objectForClassKey:_class];
            [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> getObject: (SUBCLASS EXISTED) key=%@, type=%@ [count=%d]", self, [self objectKey:key], type, dict.count];
            return obj;
        }
    }
    
    [DebLog log:_ON_READERS_LOG_ text:@"ReaderReferenceCache <%@> -> getObject: (OBJECT DON'T EXIST) key=%@, type=%@", self, [self objectKey:key], type];
    
    return nil;
}

-(void)cleanCache {
    [cache removeAllObjects];
}


@end
