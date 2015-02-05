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

#import "ProtectedBackendlessGeoQuery.h"
#import "DEBUG.h"

@interface ProtectedBackendlessGeoQuery () {
    BackendlessGeoQuery *_query;
}
@end

@implementation ProtectedBackendlessGeoQuery

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

-(BackendlessGeoQuery *)query {
    return _query.copy;
}

-(void)pageSize:(int)pageSize {
    [_query pageSize:pageSize];
}

-(void)offset:(int)offset {
    [_query offset:offset];
}

-(double)latitude {
    return _query.valLatitude;
}

-(double)longitude {
    return _query.valLongitude;
}

-(double)radius {
    return _query.valRadius;
}

-(UNITS)units {
    return _query.valUnits;
}

-(NSArray *)categories {
    return _query.valCategories.copy;
}

-(BOOL)includeMeta {
    return _query.valIncludeMeta;
}

-(NSDictionary *)metadata {
    return _query.valMetadata.copy;
}

-(NSArray *)searchRectangle {
    return _query.valSearchRectangle.copy;
}

-(int)pageSize {
    return _query.valPageSize;
}

-(int)offset {
    return _query.valOffset;
}

-(NSString *)whereClause {
    return _query.whereClause.copy;
}

-(NSDictionary *)relativeFindMetadata {
    return _query.relativeFindMetadata.copy;
}

-(double)relativeFindPercentThreshold {
    return _query.valRelativeFindPercentThreshold;
}

-(double)dpp {
    return _query.valDpp;
}

-(int)clusterGridSize {
    return _query.valClusterGridSize;
}

@end
