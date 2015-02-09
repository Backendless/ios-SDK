//
//  ProtectedBackendlessGeoQuery.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2015 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "ProtectedBackendlessGeoQuery.h"
#import "Backendless.h"
#import "DEBUG.h"

#define FAULT_GEO_QUERY_METHOD_PERMISSION [Fault fault:@"Changing the property may result in invalid cluster formation. As a result the property is immutable and cannot be changed" faultCode:@"4000"]

@interface ProtectedBackendlessGeoQuery ()
@property (nonatomic,strong) BackendlessGeoQuery *query;
@end

@implementation ProtectedBackendlessGeoQuery

-(id)init {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
    }
    return self;
}

-(id)initWithCategories:(NSArray *)categories {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        [_query categories:categories];
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point pageSize:(int)pageSize offset:(int)offset {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
        _query.pageSize = @(pageSize);
        _query.offset = @(offset);
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point categories:(NSArray *)categories {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
        [_query categories:categories];
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
        _query.radius = @(radius);
        [_query units:(int)units];
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
        _query.radius = @(radius);
        [_query units:(int)units];
        [_query categories:categories];
    }
    return self;
}

-(id)initWithPoint:(GEO_POINT)point radius:(double)radius units:(UNITS)units categories:(NSArray *)categories metadata:(NSDictionary *)metadata {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        _query.latitude = @(point.latitude);
        _query.longitude = @(point.longitude);
        _query.radius = @(radius);
        [_query units:(int)units];
        [_query categories:categories];
        [_query metadata:metadata];
    }
    return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        [_query searchRectangle:nordWest southEast:southEast];
    }
    return self;
}

-(id)initWithRect:(GEO_POINT)nordWest southEast:(GEO_POINT)southEast categories:(NSArray *)categories {
    
    if ( (self=[super init]) ) {
        _query = [BackendlessGeoQuery new];
        [_query searchRectangle:nordWest southEast:southEast];
        [_query categories:categories];
    }
    return self;
}

-(id)initWithQuery:(BackendlessGeoQuery *)query {
    
    if ( (self=[super init]) ) {
        _query = [query retain];
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC ProtectedBackendlessGeoQuery: %@", self];
    
    [_query release];
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

+(id)protectedQuery:(BackendlessGeoQuery *)query {
    return [[[ProtectedBackendlessGeoQuery alloc] initWithQuery:query] autorelease];
}

-(BackendlessGeoQuery *)geoQuery {
    return _query.copy;
}

#pragma mark -
#pragma mark Overrided Getters / Setters

-(NSNumber *)latitude {
    return _query.latitude.copy;
}

-(void)setLatitude:(NSNumber *)latitude {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)longitude {
    return _query.longitude.copy;
}

-(void)setLongitude:(NSNumber *)longitude {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)radius {
    return _query.radius.copy;
}

-(void)setRadius:(NSNumber *)radius {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSString *)units {
    return _query.units.copy;
}

-(void)setUnits:(NSString *)units {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSMutableArray *)categories {
    return _query.categories.copy;
}

-(void)setCategories:(NSMutableArray *)categories {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)includeMeta {
    return _query.includeMeta.copy;
}

-(void)setIncludeMeta:(NSNumber *)includeMeta {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSMutableDictionary *)metadata {
    return _query.metadata.copy;
}

-(void)setMetadata:(NSMutableDictionary *)metadata {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSArray *)searchRectangle {
    return _query.searchRectangle.copy;
}

-(void)setSearchRectangle:(NSArray *)searchRectangle {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)pageSize {
    return _query.pageSize;
}

-(void)setPageSize:(NSNumber *)pageSize {
    _query.pageSize = pageSize;
}

-(NSNumber *)offset {
    return _query.offset;
}

-(void)setOffset:(NSNumber *)offset {
    _query.offset = offset;
}

-(NSString *)whereClause {
    return _query.whereClause.copy;
}

-(void)setWhereClause:(NSString *)whereClause {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSDictionary *)relativeFindMetadata {
    return _query.relativeFindMetadata.copy;
}

-(void)setRelativeFindMetadata:(NSDictionary *)relativeFindMetadata {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)relativeFindPercentThreshold {
    return _query.relativeFindPercentThreshold.copy;
}

-(void)setRelativeFindPercentThreshold:(NSNumber *)relativeFindPercentThreshold {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)dpp {
    return _query.dpp.copy;
}

-(void)setDpp:(NSNumber *)dpp {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

-(NSNumber *)clusterGridSize {
    return _query.clusterGridSize.copy;
}

-(void)setClusterGridSize:(NSNumber *)clusterGridSize {
    if (_query) @throw FAULT_GEO_QUERY_METHOD_PERMISSION;
}

#pragma mark -
#pragma mark NSCopying Methods

-(id)copyWithZone:(NSZone *)zone {
    return [ProtectedBackendlessGeoQuery protectedQuery:_query];
}

@end
