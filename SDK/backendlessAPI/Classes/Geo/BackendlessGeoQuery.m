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

#define DEFAULT_PAGE_SIZE 100
#define DEFAULT_OFFSET 0
#define CLUSTER_SIZE_DEFAULT_VALUE 100

@interface BackendlessGeoQuery () {
    UNITS queryUnits;
}
@end

@implementation BackendlessGeoQuery

-(void)defaultInit {
    
    self.latitude = @0.0;
    self.longitude = @0.0;
    self.radius = @0.0;
    self.units = nil;
    self.categories = nil;
    self.includeMeta = @NO;
    self.metadata = nil;
    self.searchRectangle = nil;
    self.pageSize = @((int)DEFAULT_PAGE_SIZE);
    self.offset = @((int)DEFAULT_OFFSET);
    self.whereClause = nil;
    self.relativeFindPercentThreshold = @0.0;
    self.relativeFindMetadata = nil;
    self.dpp = nil;
    self.clusterGridSize = nil;
    
    queryUnits = -1;
}

-(id)init {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
	}
	return self;
}

-(id)initWithCategories:(NSArray *)categories {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
        [self categories:categories];
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point pageSize:(int)pageSize offset:(int)offset {
	
    if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
        self.pageSize = @(pageSize);
        self.offset = @(offset);
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
        [self categories:categories];
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
        self.radius = @(radius);
        [self units:(int)units];
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
        self.radius = @(radius);
        [self units:(int)units];
        [self categories:categories];
	}
	return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories metadata:(NSDictionary *)metadata {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        self.latitude = @(point.latitude);
        self.longitude = @(point.longitude);
        self.radius = @(radius);
        [self units:(int)units];
        [self categories:categories];
        [self metadata:metadata];
	}
	return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        [self searchRectangle:nordWest southEast:southEast];
	}
	return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)categories {
    
	if ( (self=[super init]) ) {
        [self defaultInit];
        [self searchRectangle:nordWest southEast:southEast];
        [self categories:categories];
	}
	return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"BackendlessGeoQuery: latitude:%@, lonitude:%@, radius:%@, units:%@, searchRectangle:%@, categories:%@, includeMeta:%@, metadata:%@, pageSize:%@, offset:%@, whereClause:\'%@\', dpp:%@, clusterGridSize:%@, relativeFindPercentThreshold:%@, relativeFindMetadata:%@", self.latitude, self.longitude, self.radius, self.units, self.searchRectangle, self.categories, self.includeMeta, self.metadata, self.pageSize, self.offset, self.whereClause, self.dpp, self.clusterGridSize, self.relativeFindPercentThreshold, self.relativeFindMetadata];
}

+(id)query {
    return [[BackendlessGeoQuery new] autorelease];
}

+(id)queryWithCategories:(NSArray *)categories {
    return [[[BackendlessGeoQuery alloc] initWithCategories:categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point pageSize:(int)pageSize offset:(int)offset {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point pageSize:pageSize offset:offset] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point categories:(NSArray *)categories {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point categories:categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:radius units:units] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:radius units:units categories:categories] autorelease];
}

+(id)queryWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories metadata:(NSDictionary *)metadata {
    return [[[BackendlessGeoQuery alloc] initWithPoint:point radius:radius units:units categories:categories metadata:metadata] autorelease];
}

+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    return [[[BackendlessGeoQuery alloc] initWithRect:nordWest southEast:southEast] autorelease];
}

+(id)queryWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)categories {
    return [[[BackendlessGeoQuery alloc] initWithRect:nordWest southEast:southEast categories:categories] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessGeoQuery: %@", self];
    
    [self.latitude release];
    [self.longitude release];
    [self.radius release];
    [self.units release];
    [self.categories release];
    [self.includeMeta release];
    [self.metadata release];
    [self.searchRectangle release];
    [self.pageSize release];
    [self.offset release];
	[self.whereClause release];
    [self.relativeFindPercentThreshold release];
    [self.relativeFindMetadata release];
    [self.dpp release];
    [self.clusterGridSize release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(double)valLatitude {
    return self.latitude.doubleValue;
}

-(void)latitude:(double)latitude {
    self.latitude = @(latitude);
}

-(double)valLongitude {
    return self.longitude.doubleValue;
}

-(void)longitude:(double)longitude {
    self.longitude = @(longitude);
}

-(double)valRadius {
    return self.radius.doubleValue;
}

-(void)radius:(double)radius {
    self.radius = @(radius);
}

-(UNITS)valUnits {
    return queryUnits;
}

static const char * const backendless_geo_query_units[] = { "METERS", "MILES", "YARDS", "KILOMETERS", "FEET" };

-(void)units:(UNITS)units {
    queryUnits = units;
    self.units = [NSString stringWithUTF8String:backendless_geo_query_units[(int)units]];
}

-(NSArray *)valCategories {
    return self.categories;
}

-(void)categories:(NSArray *)categories {
    [self.categories removeAllObjects];
    self.categories = categories? [NSMutableArray arrayWithArray:categories] : nil;
}

-(BOOL)valIncludeMeta {
    return self.includeMeta.boolValue;
}

-(void)includeMeta:(BOOL)includeMeta {
    self.includeMeta = @(includeMeta);
}

-(NSDictionary *)valMetadata {
    return self.metadata;
}

-(void)metadata:(NSDictionary *)metadata {
    if (metadata && metadata.count) [self includeMeta:YES];
    [self.metadata removeAllObjects];
    self.metadata = metadata? [NSMutableDictionary dictionaryWithDictionary:metadata] : nil;
}

-(NSArray *)valSearchRectangle {
    return self.searchRectangle;
}

-(void)searchRectangle:(NSArray *)searchRectangle {
    self.searchRectangle = searchRectangle;
}

-(int)valPageSize {
    return self.pageSize.intValue;
}

-(void)pageSize:(int)pageSize {
    self.pageSize = @(pageSize);
}

-(int)valOffset {
    return self.offset.intValue;
}

-(void)offset:(int)offset {
    self.offset = @(offset);
}

-(double)valRelativeFindPercentThreshold {
    return self.relativeFindPercentThreshold.doubleValue;
}

-(void)relativeFindPercentThreshold:(double)percent {
    self.relativeFindPercentThreshold = @(percent);
}

-(double)valDpp {
    return self.dpp.doubleValue;
}

-(void)dpp:(double)dpp {
    self.dpp = @(dpp);
}

-(int)valClusterGridSize {
    return self.clusterGridSize.intValue;
}

-(void)clusterGridSize:(int)size {
    self.clusterGridSize = @(size);
}

-(void)searchRectangle:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    [self searchRectangle:@[@(nordWest.latitude), @(nordWest.longitude), @(southEast.latitude), @(southEast.longitude)]];
}

-(BOOL)addCategory:(NSString *)category {
    
    if (!category)
        return NO;
    
    self.categories? [self.categories addObject:category] : [self categories:@[category]];
    return YES;
}

-(BOOL)putMetadata:(NSString *)key value:(id)value {
    
    if (!key || !value)
        return NO;
    
    self.metadata? [self.metadata setValue:value forKey:key] : [self metadata:@{key:value}];
    return YES;
}

-(BOOL)putRelativeFindMetadata:(NSString *)key value:(id)value {
    
    if (!key || !value)
        return NO;
    
    if (self.relativeFindMetadata) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.relativeFindMetadata];
        [dict setValue:value forKey:key];
        self.relativeFindMetadata = dict;
    }
    else {
        self.relativeFindMetadata = @{key:value};
    }
    return YES;
}

-(void)setClusteringParams:(double)degreePerPixel clusterGridSize:(int)size {
    self.dpp = @(degreePerPixel);
    self.clusterGridSize = @(size);
}

-(void)setClusteringParams:(double)westLongitude eastLongitude:(double)eastLongitude mapWidth:(int)mapWidth {
    [self setClusteringParams:westLongitude eastLongitude:eastLongitude mapWidth:mapWidth clusterGridSize:CLUSTER_SIZE_DEFAULT_VALUE];
}

-(void)setClusteringParams:(double)westLongitude eastLongitude:(double)eastLongitude mapWidth:(int)mapWidth clusterGridSize:(int)clusterGridSize {
    
    double longDiff = eastLongitude - westLongitude;
    if( longDiff < 0 ) {
        longDiff += 360;
    }
    
    double degreePerPixel = longDiff/mapWidth;
    [self setClusteringParams:degreePerPixel clusterGridSize:clusterGridSize];
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    
    BackendlessGeoQuery *query = [BackendlessGeoQuery query];
    query.latitude = self.latitude.copy;
    query.longitude = self.longitude.copy;
    query.radius = self.radius.copy;
    query.units = self.units.copy;
    query.categories = self.categories.copy;
    query.includeMeta = self.includeMeta.copy;
    query.metadata = self.metadata.copy;
    query.searchRectangle = self.searchRectangle.copy;
    query.pageSize = self.pageSize.copy;
    query.offset = self.offset.copy;
    query.whereClause = self.whereClause.copy;
    query.relativeFindPercentThreshold = self.relativeFindPercentThreshold.copy;
    query.relativeFindMetadata = self.relativeFindMetadata.copy;
    query.dpp = self.dpp.copy;
    query.clusterGridSize = self.clusterGridSize.copy;
    return query;
}

@end
