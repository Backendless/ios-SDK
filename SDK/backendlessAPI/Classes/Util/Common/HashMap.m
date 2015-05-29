//
//  HashMap.m
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

#import "HashMap.h"


@implementation HashMap

-(id)init {
    if( (self=[super init] )) {
		_node = [[NSMutableDictionary alloc] init];
    }
	return self;
}

-(id)initWithNode:(NSDictionary *)dict {
    if( (self=[super init] )) {
		_node = (dict) ? [[NSMutableDictionary alloc] initWithDictionary:dict] : [[NSMutableDictionary alloc] init];
    }
	return self;
}

-(void)dealloc {
	
    [self clear];
	[_node release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)push:(NSString *)key withObject:(id)it {
	
	if (!key)
		return NO;	
    
    @synchronized (self) {
        [_node setObject:it?it:[NSNull null] forKey:key];
    }
	
	return YES;
}

-(BOOL)add:(NSString *)key withObject:(id)it {
	
	if (!key || [_node valueForKey:key])
		return NO;	
    
    @synchronized (self) {
        [_node setObject:it?it:[NSNull null] forKey:key];
    }
	
	return YES;
}

-(id)get:(NSString *)key {
	return key?[_node valueForKey:key]:nil;
}

-(BOOL)pop:(NSString *)key withObject:(id)it {	

    if (!key || !it || (it != [_node valueForKey:key]))
        return NO;
        
    @synchronized (self) {
		[_node removeObjectForKey:key];
	}
    
    return YES;
}

-(BOOL)del:(NSString *)key {
	return [self pop:key withObject:[self get:key]];
}

-(NSUInteger)count {
	return _node.count;
}

-(NSArray *)keys {
	return [_node allKeys];
}

-(NSArray *)values {
	return [_node allValues];
}

-(void)clear {
    
    if (!_node.count)
        return;
    
    @synchronized (self) {
        [_node removeAllObjects];
    }
}

-(Class)hashClass {
	return [_node class];
}

@end
