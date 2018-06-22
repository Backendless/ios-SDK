//
//  CrowdNode.m
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

#import "CrowdNode.h"


@implementation CrowdNode
@synthesize node;

-(id)init {	
	if ( (self=[super init] )) 
		node = [[NSMutableDictionary alloc] init];
	
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
	
    if (!it)
		it = [NSNull null];	
	
	if ([node valueForKey:key]) 
		[node removeObjectForKey:key];	
	[node setObject:it forKey:key];	
	
	return YES;
}

-(BOOL)add:(NSString *)key withObject:(id)it {
	
	if (!key || [node valueForKey:key])
		return NO;	
	
    if (!it)
		it = [NSNull null];	

	[node setObject:it forKey:key];	
	
	return YES;
}

-(id)get:(NSString *)key {
	if (!key) 
		return nil;
	
	return [node valueForKey:key];
}

-(BOOL)pop:(NSString *)key withObject:(id)it {	
	
	if (key && it && (it == [node valueForKey:key])) {
		[node removeObjectForKey:key];		
		return YES;
	}
	return NO;
}

-(BOOL)del:(NSString *)key {	
	return [self pop:key withObject:[self get:key]];
}

-(int)count {
	return (int)node.count;
}

-(NSArray *)keys {
	return [node allKeys];
}

-(void)clear {
	[node removeAllObjects];
}

-(Class)nodeClass {
	return [node class];
}

@end
