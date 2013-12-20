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
@synthesize node;
-(id)init {	
	if( (self=[super init] )) 
		node = [[NSMutableDictionary alloc] init];
	
	return self;
}

-(id)initWithNode:(NSDictionary *)dict {
	if( (self=[super init] ))
		node = (dict) ? [[NSMutableDictionary alloc] initWithDictionary:dict] : [[NSMutableDictionary alloc] init];
	
	return self;
}

-(void)dealloc {
	
    [self clear];
	[node release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)push:(NSString *)key withObject:(id)it {
	
	if (!key)
		return NO;	
    
    @synchronized (self) {
        [node setObject:it?it:[NSNull null] forKey:key];
    }
	
	return YES;
}

-(BOOL)add:(NSString *)key withObject:(id)it {
	
	if (!key || [node valueForKey:key])
		return NO;	
    
    @synchronized (self) {
        [node setObject:it?it:[NSNull null] forKey:key];
    }
	
	return YES;
}

-(id)get:(NSString *)key {
	return key?[node valueForKey:key]:nil;
}

-(BOOL)pop:(NSString *)key withObject:(id)it {	

    if (!key || !it || (it != [node valueForKey:key]))
        return NO;
        
    @synchronized (self) {
		[node removeObjectForKey:key];
	}
    
    return YES;
}

-(BOOL)del:(NSString *)key {	
	return [self pop:key withObject:[self get:key]];
}

-(NSUInteger)count {
	return node.count;
}

-(NSArray *)keys {
	return [node allKeys];
}

-(NSArray *)values {
	return [node allValues];
}

-(void)clear {
    
    if (!node.count)
        return;
    
    @synchronized (self) {
        [node removeAllObjects];
    }
}

-(Class)hashClass {
	return [node class];
}

@end
