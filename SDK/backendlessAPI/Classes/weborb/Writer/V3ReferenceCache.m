//
//  V3ReferenceCache.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3ReferenceCache.h"
#import "DEBUG.h"
#import "MessageWriter.h"

@interface V3ReferenceCache () {
	NSMutableArray	*objectCache;
	NSMutableArray	*stringCache;
	NSMutableArray	*traitsCache;
}
@end

@implementation V3ReferenceCache

-(id)init {	
	if ( (self=[super init]) ) {
		objectCache = [NSMutableArray new];
        stringCache = [NSMutableArray new];
        traitsCache = [NSMutableArray new];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ReferenceCache"];
    
    [self reset];
	
	[objectCache release];
	[stringCache release];
	[traitsCache release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(int)getId:(id)obj cache:(NSArray *)refs {
    
    if (!obj  || !refs)
        return -1;

#if _ON_EQUAL_BY_INSTANCE_ADDRESS_
    for (int i = 0; i < refs.count; i++) {
        id ref = [refs objectAtIndex:i];
        if (ref == obj) {
            [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> getId: %d -> %@ ", i, obj];
            return i;
        }
    }
    return -1;
#else
    NSUInteger val = [refs indexOfObject:obj];
    [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> getId: %d -> %@", (int)val, obj];
    return (val != NSNotFound) ? (int)val : -1;
#endif
}

#pragma mark -
#pragma mark Public Methods

-(void)reset {
	[objectCache removeAllObjects];
	[stringCache removeAllObjects];
	[traitsCache removeAllObjects];
}

-(void)addObject:(id)obj {
    
    if (!obj)
        obj = [NSNull null];
    
    if ([self getObjectId:obj] == -1) {
        [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> addObject: <%@> %d -> %@ ", [obj class], objectCache.count, obj];
        [objectCache addObject:obj];
    }
}

-(int)getObjectId:(id)obj {
	return [self getId:obj cache:objectCache];
}

-(void)addString:(NSString *)obj {
    
    if (obj && obj.length && [self getStringId:obj] == -1) {
        [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> addString: %d -> %@ ", stringCache.count, obj];
        [stringCache addObject:obj];
    }
}

-(int)getStringId:(NSString *)obj {
#if _ON_EQUAL_BY_STRING_VALUE_
    for (int i = 0; i < stringCache.count; i++) {
        NSString *ref = [stringCache objectAtIndex:i];
        if ([obj isEqualToString:ref]) {
            [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> getStringId: %d -> %@ ", i, obj];
            return i;
        }
    }
    return -1;
#else
	return [self getId:obj cache:stringCache];
#endif
}

-(void)addToTraitsCache:(NSString *)className {
    
    if (className && className.length && [self getTraitsId:className] == -1) {
        [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> addToTraitsCache: %d -> %@", traitsCache.count, className];
        [traitsCache addObject:className];
    }
}

-(int)getTraitsId:(NSString *)className {
#if _ON_EQUAL_BY_STRING_VALUE_
    for (int i = 0; i < traitsCache.count; i++) {
        NSString *ref = [traitsCache objectAtIndex:i];
        if ([className isEqualToString:ref]) {
            [DebLog log:_ON_WRITERS_LOG_ text:@"V3ReferenceCache -> getTraitsId: %d -> %@ ", i, className];
            return i;
        }
    }
    return -1;
#else
    return [self getId:className cache:traitsCache];
#endif
}

@end
