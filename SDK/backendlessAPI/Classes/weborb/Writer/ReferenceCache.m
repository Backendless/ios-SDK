//
//  ReferenceCache.m
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
