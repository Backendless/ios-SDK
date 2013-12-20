//
//  BackendlessEntity.m
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

#import "BackendlessEntity.h"
#import "DEBUG.h"

@implementation BackendlessEntity

@synthesize objectId;
@synthesize __meta;
@synthesize created;
@synthesize updated;

-(id)init {
	if ( (self=[super init]) ) {
        objectId = nil;
        __meta = nil;
        created = nil;
        updated = nil;
	}
	
	return self;
}

+(BackendlessEntity *)entity {
    return [[[BackendlessEntity alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessEntity"];
    
    [created release];
    [objectId release];
	[__meta release];
    [updated release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessEntity> objectId: '%@' meta: '%@'", objectId, __meta];
}

@end
