//
//  BackendlessCollection.m
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

#import "BackendlessCollection.h"
#import "DEBUG.h"
#import "Responder.h"
#import "HashMap.h"
#import "Backendless.h"
#import "QueryOptions.h"
#import "BackendlessEntity.h"
#import "PersistenceService.h"

#pragma mark -
#pragma mark PersistenceResponder Class

@interface PersistenceResponder : Responder {
    HashMap *cache;
}

+(id)responder:(HashMap *)_cache chained:(Responder *)responder;
-(id)onDownloadPage:(id)response;
@end

@implementation PersistenceResponder

-(id)initWithCache:(HashMap *)_cache chained:(Responder *)responder {
    
    if ( (self = [super init]) ) {
        _responder = self;
        _responseHandler = @selector(onDownloadPage:);
        _errorHandler = nil;
        self.chained = responder;
        cache = _cache;
    }
    
    return self;
    
}

+(id)responder:(HashMap *)_cache chained:(Responder *)responder {
    return [[[PersistenceResponder alloc] initWithCache:_cache chained:responder] autorelease];
}

// async callback

-(id)onDownloadPage:(id)response {
    
    BackendlessCollection *bc = (BackendlessCollection *)response;
    
    if (cache) {
        
        for (id value in bc.data) {
            [cache push:[[Types propertyDictionary:value] objectForKey:PERSIST_OBJECT_ID] withObject:value];
        }
    }
    
    return bc;
}

@end


#pragma mark -
#pragma mark BackendlessCollection Class

@interface BackendlessCollection ()
-(void)defaultInit;
@end

@implementation BackendlessCollection
@synthesize data, backendlessQuery;

-(id)init {
	if ( (self=[super init]) ) {
        [self defaultInit];
	}
	
	return self;
}

-(id)init:(BOOL)isCaching {
	if ( (self=[super init]) ) {
        [self defaultInit];
        [self setCaching:isCaching];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessCollection: %@", self];
    
    [backendlessQuery release];
    [data release];
    [cachedData release];
    
	[super dealloc];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessCollection> -> type: %@, offset: %@, pageSize: %@, totalObjects: %@, data: %@, query: %@", type, @(aOffset), @(pageSize), @(aTotalObjects), data, backendlessQuery];
}

#pragma mark -
#pragma mark getters / setters

-(NSString *)getEntityName {
    return [Types typeClassName:type];
}

-(void)setEntityName:(NSString *)className {
    type = [Types classByName:className];
}

-(NSNumber *)getTotalObjects {
    return [NSNumber numberWithInteger:aTotalObjects];
}

-(void)setTotalObjects:(NSNumber *)_totalObjects {
    aTotalObjects = [_totalObjects intValue];
}

-(NSNumber *)getOffset {
    return [NSNumber numberWithInteger:aOffset];
}

-(void)setOffset:(NSNumber *)_offset {
    aOffset = [_offset intValue];
}

#pragma mark -
#pragma mark Private Methods

-(void)defaultInit {
    
    data = nil;
    type = [NSObject class];
    aTotalObjects = 0;
    aOffset = 0;    
    pageSize = 20;
    cachedData = nil;
}
 
// sync

-(NSArray *)downloadPage:(NSInteger)_offset page:(NSInteger)_pageSize update:(BOOL)forceUpdate {
    
    forceUpdate = YES;
    
    if (!cachedData || forceUpdate) {
        if ([self.backendlessQuery isKindOfClass:[BackendlessGeoQuery class]]) {
            BackendlessGeoQuery *geoQuery = self.backendlessQuery;
            geoQuery.offset = [NSNumber numberWithInteger:_offset];
            geoQuery.pageSize = [NSNumber numberWithInteger:_pageSize];
            id response = [backendless.geoService getPoints:geoQuery];
            return [response isKindOfClass:[Fault class]] ? response : ((BackendlessCollection *)response).data;
        }
        else
        {
            BackendlessDataQuery *dataQuery = self.backendlessQuery;//BACKENDLESS_DATA_QUERY;
            dataQuery.queryOptions = [QueryOptions query:(int)_pageSize offset:(int)_offset];
            id response = [backendless.persistenceService find:type dataQuery:dataQuery];
            return [response isKindOfClass:[Fault class]] ? response : ((BackendlessCollection *)response).data;
        }
    }
    
    NSMutableArray *result = [NSMutableArray array];
    return result;
}

// async

-(void)downloadPage:(NSInteger)_offset page:(NSInteger)_pageSize update:(BOOL)forceUpdate responder:(id <IResponder>)responder {
    
    forceUpdate = YES;
    
    if (!cachedData || forceUpdate) {
        if ([self.backendlessQuery isKindOfClass:[BackendlessGeoQuery class]]) {
            BackendlessGeoQuery *geoQuery = self.backendlessQuery;
            geoQuery.offset = [NSNumber numberWithInteger:_offset];
            geoQuery.pageSize = [NSNumber numberWithInteger:_pageSize];
            [backendless.geoService getPoints:geoQuery responder:responder];
        }
        else
        {
            BackendlessDataQuery *dataQuery = self.backendlessQuery;
            dataQuery.queryOptions = [QueryOptions query:(int)_pageSize offset:(int)_offset];
            [backendless.persistenceService find:type dataQuery:dataQuery responder:responder];
        }
        return;
    }    
}

#pragma mark -
#pragma mark Public Methods

-(Class)type {
    return type;
}

-(NSInteger)valTotalObjects {
    return aTotalObjects;
}

-(NSInteger)valOffset {
    return aOffset;
}

-(void)offset:(NSInteger)_offset {
    aOffset = _offset;
}

-(void)nextPageOffset {
    aOffset += pageSize;
}

-(void)previousPageOffset {
    aOffset = (aOffset > pageSize) ? (aOffset - pageSize) : 0;
}

-(NSInteger)valPageSize {
    return pageSize;
}

-(void)pageSize:(NSInteger)_pageSize {
    pageSize = _pageSize;
}

-(void)setCaching:(BOOL)isCaching {
    
    if (isCaching && !cachedData)
        cachedData = [HashMap new];
    else
        if (!isCaching && cachedData) {
            [cachedData release];
            cachedData = nil;
        }
}

-(NSArray *)getCurrentPage {
    return data;
}

-(void)cleanCache {
    if (cachedData) [cachedData clear];
}

// sync

-(BackendlessCollection *)nextPage {
    return [self nextPage:NO];
}

-(BackendlessCollection *)nextPage:(BOOL)forceUpdate {
    
    NSInteger _offset = aOffset+pageSize;
    id response = [self downloadPage:_offset page:pageSize update:forceUpdate];
    if ([response isKindOfClass:[Fault class]])
        return response;
    
    self.data = response;
    aOffset = _offset;
    
    return self;
}

-(BackendlessCollection *)previousPage {
    return [self previousPage:NO];    
}

-(BackendlessCollection *)previousPage:(BOOL)forceUpdate {
    
    NSInteger _offset = (aOffset > pageSize) ? (aOffset - pageSize) : 0;
    id response = [self downloadPage:_offset page:pageSize update:forceUpdate];
    if ([response isKindOfClass:[Fault class]])
        return response;
    
    self.data = response;
    aOffset = _offset;
    
    return self;    
}

-(BackendlessCollection *)getPage:(NSInteger)_offset {
    return [self getPage:_offset update:NO];
}

-(BackendlessCollection *)getPage:(NSInteger)_offset update:(BOOL)forceUpdate {
    
    id response = [self downloadPage:_offset page:pageSize update:forceUpdate];
    if ([response isKindOfClass:[Fault class]])
        return response;
    
    self.data = response;
    aOffset = _offset;
    
    return self;
}

-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize {
    return [self getPage:_offset pageSize:_pageSize update:NO];
}

-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate {
    
    id response = [self downloadPage:_offset page:_pageSize update:forceUpdate];
    if ([response isKindOfClass:[Fault class]])
        return response;
    
    self.data = response;
    aOffset = _offset;
    pageSize = _pageSize;
    
    return self;
}

-(BackendlessCollection *)removeAll {
    
    //[self getPage:0];
    
    while (YES) {
        
        for (id obj in self.data) {
            
            NSString *objectId = [backendless.persistenceService getObjectId:obj];
            if ([objectId isKindOfClass:[NSString class]])
                [backendless.persistenceService remove:[obj class] sid:objectId];
            else
                [backendless.persistenceService remove:obj];
        }
        
        if (([self valOffset] + self.data.count) < self.valTotalObjects) {
            [self nextPage];
            continue;
        }
        
        break;
    }
    
    return self;
}

// async methods with responder

-(void)nextPageAsync:(id <IResponder>)responder {
    [self nextPage:NO responder:responder];
}

-(void)nextPage:(BOOL)forceUpdate responder:(id <IResponder>)responder{
    NSInteger _offset = aOffset + pageSize;
    [self downloadPage:_offset page:pageSize update:forceUpdate responder:responder];
}

-(void)previousPageAsync:(id <IResponder>)responder {
    [self previousPage:NO responder:responder];
}

-(void)previousPage:(BOOL)forceUpdate responder:(id <IResponder>)responder {
    
    if (aOffset == 0) {
        [responder responseHandler:self];
        return;
    }
    
    NSInteger _offset = (aOffset > pageSize) ? (aOffset - pageSize) : 0;
    [self downloadPage:_offset page:pageSize update:forceUpdate responder:responder];
}

-(void)getPage:(NSInteger)_offset responder:(id <IResponder>)responder {
    [self getPage:_offset update:NO responder:responder];
}

-(void)getPage:(NSInteger)_offset update:(BOOL)forceUpdate responder:(id <IResponder>)responder {
    [self downloadPage:_offset page:pageSize update:forceUpdate responder:responder];
}

-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize responder:(id <IResponder>)responder {
    [self getPage:_offset pageSize:_pageSize update:NO responder:responder];
}

-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate responder:(id <IResponder>)responder {
    [self downloadPage:_offset page:_pageSize update:forceUpdate responder:responder];
}

-(void)removeAll:(id <IResponder>)responder {
    [self removeAll:^(BackendlessCollection *bc) {
        [responder responseHandler:bc];
    }
    error:^(Fault *fault) {
        [responder errorHandler:fault];
    }];
}

// async methods with block-base callbacks

-(void)nextPageAsync:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self nextPageAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)nextPage:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self nextPage:forceUpdate responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)previousPageAsync:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self previousPageAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)previousPage:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self previousPage:forceUpdate responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPage:(NSInteger)_offset response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPage:_offset responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPage:(NSInteger)_offset update:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPage:_offset update:forceUpdate responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPage:_offset pageSize:_pageSize responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPage:_offset pageSize:_pageSize update:forceUpdate responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeAll:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    
    for (id obj in self.data) {
        
        NSString *objectId = [backendless.persistenceService getObjectId:obj];
        if ([objectId isKindOfClass:[NSString class]]) {
        
            [backendless.persistenceService
             remove:[obj class] sid:objectId
             response:nil
             error:^(Fault *fault) {
                 [DebLog logY:@"BackendlessCollection -> removeAll: FAULT: %@ ", fault];
                 errorBlock(fault);
             }];
        }
        else {
            
            [backendless.persistenceService
             remove:obj
             response:nil
             error:^(Fault *fault) {
                 [DebLog logY:@"BackendlessCollection -> removeAll: FAULT: %@", fault];
                 errorBlock(fault);
             }];
        }
    }
    
    if (([self valOffset] + self.data.count) < self.valTotalObjects) {
        [self nextPageAsync:^(BackendlessCollection *bc) {
            [self removeAll:responseBlock error:errorBlock];
        }
        error:^(Fault *fault) {
            [DebLog logY:@"BackendlessCollection -> removeAll: FAULT: %@", fault];
            errorBlock(fault);
        }];
    }
    else {
        responseBlock(self);
    }
}

@end
