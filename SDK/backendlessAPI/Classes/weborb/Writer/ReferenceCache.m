//
//  ReferenceCache.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 29.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ReferenceCache.h"
#import "DEBUG.h"
#import "MessageWriter.h"

@interface ReferenceCache () {
    NSMutableArray  *cache;
}
@end

@implementation ReferenceCache

-(id)init {	
	if ( (self=[super init]) ) {
        cache = [NSMutableArray new];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ReferenceCache"];
	
	[cache removeAllObjects];
	[cache release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)reset {
	[cache removeAllObjects];
}

-(void)addObject:(id)obj {
    
    if (!obj)
        obj = [NSNull null];
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"ReferenceCache -> addObject: <%@> %d -> %@ ", [obj class], cache.count, obj];
    
    if ([self getId:obj] == -1)
        [cache addObject:obj];
}

-(void)addString:(NSString *)obj {
	[self addObject:obj];
}

-(int)getStringId:(NSString *)obj {
	return [self getId:obj];
}

-(int)getObjectId:(id)obj {
	return [self getId:obj];
}

-(int)getId:(id)obj {
    
    if (!obj)
        return -1;
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"ReferenceCache -> getId: %@", obj];
    
#if _ON_EQUAL_BY_INSTANCE_ADDRESS_
    for (int i = 0; i < cache.count; i++) {
        id ref = [cache objectAtIndex:i];
        if (ref == obj) {
            return i;
        }
    }
    return -1;
#else
    NSUInteger val = [cache indexOfObject:obj];
    return (val != NSNotFound) ? (int)val : -1;
#endif
}

@end
