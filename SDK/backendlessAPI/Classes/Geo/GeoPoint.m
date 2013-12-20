//
//  GeoPoint.m
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

#import "GeoPoint.h"
#import "DEBUG.h"

@implementation GeoPoint 

-(id)init {
	
    if ( (self=[super init]) ) {
        _objectId = nil;
        _latitude = [[NSNumber alloc] initWithDouble:0.0];
        _longitude = [[NSNumber alloc] initWithDouble:0.0];
        _categories = [NSMutableArray new];
        _metadata = [NSMutableDictionary new];
	}
	
	return self;
}

-(id)initWithPoint:(GEO_POINT)point {
	
    if ( (self=[super init]) ) {
        _objectId = nil;
        _latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        _longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        _categories = [NSMutableArray new];
        _metadata = [NSMutableDictionary new];
	}
	
	return self;
    
}

-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories {
    
	if ( (self=[super init]) ) {
        _objectId = nil;
        _latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        _longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        _categories = [[NSMutableArray alloc] initWithArray:categories];
        _metadata = [NSMutableDictionary new];
	}
	
	return self;
}

-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories metadata:(NSDictionary *)metadata {
    
	if ( (self=[super init]) ) {
        _objectId = nil;
        _latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        _longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        _categories = [[NSMutableArray alloc] initWithArray:categories];
        _metadata = [[NSMutableDictionary alloc] initWithDictionary:metadata];
	}
	
	return self;
}

+(id)geoPoint {
    return [[GeoPoint new] autorelease];
}

+(id)geoPoint:(GEO_POINT)point {
    return [[[GeoPoint alloc] initWithPoint:point] autorelease];
}

+(id)geoPoint:(GEO_POINT)point categories:(NSArray *)categories {
    return [[[GeoPoint alloc] initWithPoint:point categories:categories] autorelease];
}

+(id)geoPoint:(GEO_POINT)point categories:(NSArray *)categories metadata:(NSDictionary *)metadata {
    return [[[GeoPoint alloc] initWithPoint:point categories:categories metadata:metadata] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC GeoPoint"];
    
    [_objectId release];
    [_latitude release];
    [_longitude release];
    
    [_categories release];
    [_metadata release];
	[_distance release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods
-(float)valDistance
{
    return self.distance.floatValue;
}
-(BOOL)distance:(float)distance
{
    [_distance release];
    _distance = [[NSNumber alloc] initWithFloat:distance];
    return YES;
}
-(double)valLatitude {
    return [_latitude doubleValue];
}

-(BOOL)latitude:(double)latitude {
    
    [_latitude release];
    _latitude = [[NSNumber alloc] initWithDouble:latitude];
    return YES;
}

-(double)valLongitude {
    return [_longitude doubleValue];
}

-(BOOL)longitude:(double)longitude {
    
    [_longitude release];
    _longitude = [[NSNumber alloc] initWithDouble:longitude];
    return YES;
}

-(NSArray *)valCategories {
    return _categories;
}

-(BOOL)categories:(NSArray *)categories {
    
    [_categories release];
    _categories = (categories) ? [[NSMutableArray alloc] initWithArray:categories] : [NSMutableArray new];
    return YES;
}

-(NSDictionary *)valMetadata {
    return _metadata;
}

-(BOOL)metadata:(NSDictionary *)metadata {
    
    [_metadata release];
    _metadata = (metadata) ? [[NSMutableDictionary alloc] initWithDictionary:metadata] : [NSMutableDictionary new];
    return YES;
}

-(BOOL)addCategory:(NSString *)category {
    
    if (!category) {
        return NO;
    }
    
    [_categories addObject:category];
    return YES;
}

-(BOOL)addMetadata:(NSString *)key value:(NSString *)value {
    
    if (!key || !value) {
        return NO;
    }
    
    [_metadata setValue:value forKey:key];
    return YES;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"LAT:%g LON:%g CATEGORIES:%@ METADATA:%@ objectId = %@", [self valLatitude], [self valLongitude], _categories, _metadata, _objectId];
}


@end

@implementation SearchMatchesResult

@synthesize objectId;
@synthesize matches;
@synthesize geoPoint;
-(NSString *)description
{
    return [NSString stringWithFormat:@"GEOPOINT: %@ MATCHES: %@", geoPoint.description, matches];
}
@end