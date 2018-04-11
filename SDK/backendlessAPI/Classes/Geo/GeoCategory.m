//
//  GeoCategory.m
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

#import "GeoCategory.h"
#import "DEBUG.h"

@implementation GeoCategory

-(id)init {
	if (self = [super init]) {
        _objectId = nil;
        _name = nil;
        _size = nil;
	}
	return self;
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC GeoCategory"];
    [_objectId release];
    [_name release];
    [_size release];
	[super dealloc];
}

-(int)valSize {
    return (_size) ? [_size intValue] : 0;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"GeoCategory: id:%@, name:%@, size:%@", _objectId, _name, _size];
}

@end
