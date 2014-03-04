//
//  BackendlessGeoQuery.m
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

#import "BackendlessGeoQuery.h"
#import "DEBUG.h"

#define DEFAULT_PAGE_SIZE 20
#define DEFAULT_OFFSET 0

@interface BackendlessGeoQuery () {
    UNITS queryUnits;
}
@end

@implementation BackendlessGeoQuery
@synthesize latitude, longitude, radius, units, categories, includeMeta, metadata, searchRectangle, pageSize, offset, whereClause, relativeFindMetadata, relativeFindPercentThreshold;

-(id)init {
	
    if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;
        latitude = [[NSNumber alloc] initWithDouble:0.0];
        longitude = [[NSNumber alloc] initWithDouble:0.0];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
        whereClause = nil;
	}
	
	return self;
}

-(id)initWithCategories:(NSArray *)_categories {
	
    if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:0.0];
        longitude = [[NSNumber alloc] initWithDouble:0.0];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
        
	}
	
	return self;    
}

-(id)initWithPoint:(GEO_POINT)point {
	
    if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;    
}

-(id)initWithPoint:(GEO_POINT)point pageSize:(int)_pageSize offset:(int)_offset {
	
    if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:_pageSize];
        offset = [[NSNumber alloc] initWithInt:_offset];
	}
	
	return self;    
}

-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)_categories {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:_radius];
        [self units:(int)_units];
        categories = nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:_radius];
        [self units:(int)_units];
        categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories metadata:(NSDictionary *)_metadata {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:point.latitude];
        longitude = [[NSNumber alloc] initWithDouble:point.longitude];
        radius = [[NSNumber alloc] initWithDouble:_radius];
        [self units:(int)_units];
        categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
        metadata = (_metadata) ? [[NSMutableDictionary alloc] initWithDictionary:_metadata] : nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        searchRectangle = nil;
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:0.0];
        longitude = [[NSNumber alloc] initWithDouble:0.0];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        [self searchRectangle:nordWest southEast:southEast];
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)_categories {
    
	if ( (self=[super init]) ) {
        relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:0.0];
        relativeFindMetadata = nil;

        latitude = [[NSNumber alloc] initWithDouble:0.0];
        longitude = [[NSNumber alloc] initWithDouble:0.0];
        radius = [[NSNumber alloc] initWithDouble:0.0];
        [self units:(int)METERS];
        categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
        includeMeta = [[NSNumber alloc] initWithBool:YES];
        metadata = nil;
        [self searchRectangle:nordWest southEast:southEast];
        pageSize = [[NSNumber alloc] initWithInt:DEFAULT_PAGE_SIZE];
        offset = [[NSNumber alloc] initWithInt:DEFAULT_OFFSET];
	}
	
	return self;
}

+(id)query {
    return [[BackendlessGeoQuery new] autorelease];
}

+(id)queryWithCategories:(NSArray *)_categories {
    return [[[BackendlessGeoQuery alloc] initWithCategories:_categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point pageSize:(int)_pageSize offset:(int)_offset {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point pageSize:_pageSize offset:_offset] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point categories:(NSArray *)_categories {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point categories:_categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:_radius units:_units] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:_radius units:_units categories:_categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)_radius units:(UNITS)_units categories:(NSArray *)_categories metadata:(NSDictionary *)_metadata {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:_radius units:_units categories:_categories metadata:_metadata] autorelease];
}

+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    return [[[BackendlessGeoQuery alloc] initWithRect:nordWest southEast:southEast] autorelease];
}

+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)_categories {
    return [[[BackendlessGeoQuery alloc] initWithRect:nordWest southEast:southEast categories:_categories] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessGeoQuery: %@", self];
    
    [relativeFindPercentThreshold release];
    [relativeFindMetadata release];

    [latitude release];
    [longitude release];
    [radius release];
    [units release];
    [categories release];
    [includeMeta release];
    [metadata release];
    [searchRectangle release];
    [pageSize release];
    [offset release];
	[whereClause release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

#pragma mark -
#pragma mark Public Methods
-(float)valRelativeFindPercentThreshold{
    return relativeFindPercentThreshold.floatValue;
}
-(BOOL)relativeFindPercentThreshold:(float)_percent
{
    [relativeFindPercentThreshold release];
    relativeFindPercentThreshold = [[NSNumber alloc] initWithFloat:_percent];
    return YES;
}
-(double)valLatitude {
    return [latitude doubleValue];
}

-(BOOL)latitude:(double)_latitude {
    
    [latitude release];
    latitude = [[NSNumber alloc] initWithDouble:_latitude];
    return YES;
}

-(double)valLongitude {
    return [longitude doubleValue];
}

-(BOOL)longitude:(double)_longitude {
    
    [longitude release];
    longitude = [[NSNumber alloc] initWithDouble:_longitude];
    return YES;
}

-(double)valRadius {
    return [radius doubleValue];
}

-(BOOL)radius:(double)_radius {
    
    [radius release];
    radius = [[NSNumber alloc] initWithDouble:_radius];
    return YES;
}

-(UNITS)valUnits {
    return queryUnits;
}

static const char * const query_units[] = { "METERS", "MILES", "YARDS", "KILOMETERS", "FEET" };

-(BOOL)units:(UNITS)_units {
    
    queryUnits = _units;
    
    [units release];
    units = [[NSString alloc] initWithUTF8String:query_units[(int)_units]];
    return YES;
}

-(NSArray *)valCategories {
    return categories;
}

-(BOOL)categories:(NSArray *)_categories {
    
    [categories removeAllObjects];
    [categories release];
    categories = (_categories) ? [[NSMutableArray alloc] initWithArray:_categories] : nil;
    return YES;
}

-(BOOL)valIncludeMeta {
    return [includeMeta boolValue];
}

-(BOOL)includeMeta:(BOOL)_includeMeta {
    
    [includeMeta release];
    includeMeta = [[NSNumber alloc] initWithBool:_includeMeta];
    return YES;
}

-(NSDictionary *)valMetadata {
    return metadata;
}

-(BOOL)metadata:(NSDictionary *)_metadata {
    
    [metadata removeAllObjects];
    [metadata release];
    metadata = (_metadata) ? [[NSMutableDictionary alloc] initWithDictionary:_metadata] : nil;
    if (metadata && metadata.count) [self includeMeta:YES];
    return YES;
}

-(NSArray *)valSearchRectangle {
    return searchRectangle;
}

-(BOOL)searchRectangle:(NSArray *)_searchRectangle {
    
    [searchRectangle release];
    searchRectangle = (_searchRectangle) ? [_searchRectangle retain] : nil;//[NSArray new];
    return YES;
}

-(int)valPageSize {
    return [pageSize intValue];
}

-(BOOL)pageSize:(int)_pageSize {
    
    [pageSize release];
    pageSize = [[NSNumber alloc] initWithInt:_pageSize];
    return YES;
}

-(int)valOffset {
    return [offset intValue];
}

-(BOOL)offset:(int)_offset {
    
    [offset release];
    offset = [[NSNumber alloc] initWithInt:_offset];
    return YES;
    
}

-(BOOL)searchRectangle:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    return [self searchRectangle:[[[NSArray alloc] initWithObjects:
                                  [NSNumber numberWithDouble:nordWest.latitude],
                                  [NSNumber numberWithDouble:nordWest.longitude],
                                  [NSNumber numberWithDouble:southEast.latitude],
                                  [NSNumber numberWithDouble:southEast.longitude],
                                  nil] autorelease]];
}

-(BOOL)addCategory:(NSString *)category {
    
    if (!category) {
        return NO;
    }
    
    //(categories) ? [categories addObject:category] : [[NSMutableArray alloc] initWithObjects:categories, nil];
    
    if (categories) {
        [categories addObject:category];
    }
    else {
        categories = [[NSMutableArray alloc] initWithObjects:categories, nil];
    }
    
    return YES;   
}

-(BOOL)addMetadata:(NSString *)key value:(NSString *)value {
    
    if (!key || !value) {
        return NO;
    }
    
    (metadata) ? [metadata setValue:value forKey:key] : [[NSMutableDictionary alloc] initWithObjectsAndKeys:value, key, nil];
    return YES;
}

static char *geoServiceUnits[] = {"METERS", "MILES", "YARDS", "KILOMETERS", "FEET"};

-(NSString *)evaluation {
    return [NSString stringWithFormat:@"BackendlessGeoQuery: latitude:%@, lonitude:%@, radius:%@, units:%s, searchRectangle:%@, categories:%@, includeMeta:%@, metadata:%@, pageSize:%@, whereClause:\'%@\'", latitude, longitude, radius, geoServiceUnits[[self valUnits]], searchRectangle, categories, [self valIncludeMeta]?@"YES":@"NO", metadata, pageSize, whereClause];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"BackendlessGeoQuery: latitude:%@, lonitude:%@, radius:%@, units:%s, searchRectangle:%@, categories:%@, includeMeta:%@, metadata:%@, pageSize:%@, offset:%@, whereClause:\'%@\'", latitude, longitude, radius, geoServiceUnits[[self valUnits]], searchRectangle, categories, [self valIncludeMeta]?@"YES":@"NO", metadata, pageSize, offset, whereClause];
}

@end
