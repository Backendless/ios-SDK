//
//  MapDrivenDataStore.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2016 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "MapDrivenDataStore.h"
#include "Backendless.h"
#import "Invoker.h"
#include "Responder.h"
#import "ObjectProperty.h"
#import "ClassCastException.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is missing or null" detail:@"Entity is missing or null" faultCode:@"1900"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"objectId is missing or null" detail:@"objectId is missing or null" faultCode:@"1901"]
#define FAULT_NAME_IS_NULL [Fault fault:@"Name is missing or null" detail:@"Name is missing or null" faultCode:@"1902"]


// SERVICE NAME
static NSString *_SERVER_PERSISTENCE_SERVICE_PATH = @"com.backendless.services.persistence.PersistenceService";
// METHOD NAMES
static NSString *_METHOD_SAVE = @"save";
static NSString *_METHOD_REMOVE = @"remove";
static NSString *_METHOD_FIND = @"find";
static NSString *_METHOD_FIRST = @"first";
static NSString *_METHOD_LAST = @"last";
static NSString *_METHOD_FINDBYID = @"findById";
static NSString *_METHOD_LOAD = @"loadRelations";


@implementation MapDrivenDataStore

-(id)init {
	if ( (self=[super init]) ) {
        _tableName = nil;
        [self setClassMapping];
	}
	
	return self;
}

-(id)init:(NSString *)tableName {
	if ( (self=[super init]) ) {
        _tableName = [tableName retain];
        [self setClassMapping];
	}
	
	return self;
}

+(id)createDataStore:(NSString *)tableName {
    return [[MapDrivenDataStore alloc] init:tableName];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MapDrivenDataStore"];
    
    [_tableName release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(void)setClassMapping {
    
    if (backendless.data)
        return;
    
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.ObjectProperty" mapped:[ObjectProperty class]];
    [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
    [[Types sharedInstance] addClientClassMapping:@"java.lang.ClassCastException" mapped:[ClassCastException class]];
#if !_IS_USERS_CLASS_
    [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
#endif
    
}

-(BackendlessCollection *)fixClassCollection:(BackendlessCollection *)bc {
    
    if (bc.data.count && ![bc.data[0] isKindOfClass:NSDictionary.class]) {
        
        NSMutableArray *data = [NSMutableArray array];
        for (id item in bc.data) {
            [data addObject:[Types propertyDictionary:item]];
        }
        bc.data = [NSArray arrayWithArray:data];
    }
    return bc;
}


#pragma mark -
#pragma mark Public Methods

// sync methods with fault return (as exception)
-(NSDictionary<NSString*,id> *)save:(NSDictionary<NSString*,id> *)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_SAVE args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_REMOVE args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(BackendlessCollection *)find {
    return [self find:BACKENDLESS_DATA_QUERY];
}

-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, dataQuery?dataQuery:BACKENDLESS_DATA_QUERY];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIND args:args];
    if ([result isKindOfClass:[Fault class]])
        return result;
    
    BackendlessCollection *bc = (BackendlessCollection *)result;
    [bc pageSize:dataQuery.queryOptions.pageSize.integerValue];
    bc.query = dataQuery;
    bc.tableName = _tableName;
    return [self fixClassCollection:bc];
}

-(NSDictionary<NSString*,id> *)findFirst {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findFirst:(int)relationsDepth {
    return [self findFirst:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString*,id> *)findFirstWithRelations:(NSArray<NSString*> *)relations {
    return [self findFirst:relations relationsDepth:0];
}

-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findLast {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findLast:(int)relationsDepth {
    return [self findLast:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString*,id> *)findLastWithRelations:(NSArray<NSString*> *)relations {
    return [self findLast:relations relationsDepth:0];
}

-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId {
    return [self findByIdWithRelations:objectId relations:@[]];
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relationsDepth:(int)relationsDepth {
    return [self findById:objectId relations:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString*,id> *)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations {
    
    if (!objectId)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, objectId, relations?relations:@[]];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth {
    
    if (!objectId)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, objectId, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity {
    return [self findByEntity:entity relations:@[] relationsDepth:0];
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth {
    return [self findByEntity:entity relations:@[] relationsDepth:relationsDepth];
}

-(NSDictionary<NSString*,id> *)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations {
    return [self findByEntity:entity relations:relations?relations:@[] relationsDepth:0];
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity, relations?relations:@[], @(relationsDepth)];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args];
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(NSDictionary<NSString*,id> *)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity, relations?relations:@[]];
    id result = [invoker invokeSync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    NSMutableDictionary<NSString*,id> *entityWithRel = [NSMutableDictionary dictionaryWithDictionary:entity];
    [entityWithRel addEntriesFromDictionary:[result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result]];
    return [NSDictionary dictionaryWithDictionary:entityWithRel];
}


// sync methods with fault option

#if 0 // wrapper for work without exception

id result = nil;
@try {
    result = [self <method with fault return>];
}
@catch (Fault *fault) {
    result = fault;
}
@finally {
    if ([result isKindOfClass:Fault.class]) {
        if (fault)(*fault) = result;
        return nil;
    }
    return result;
}

#endif

-(NSDictionary<NSString*,id> *)save:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self save:entity];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSNumber *)remove:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self remove:entity];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessCollection *)findFault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self find];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessCollection *)find:(BackendlessDataQuery *)dataQuery fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self find:dataQuery];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findFirstFault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findFirst];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findFirst:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findFirst:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findFirstWithRelations:(NSArray<NSString*> *)relations fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findFirstWithRelations:relations];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findFirst:relations relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findLastFault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findLast];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findLast:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findLast:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findLastWithRelations:(NSArray<NSString*> *)relations fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findLastWithRelations:relations];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findLast:relations relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
    
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:objectId];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:objectId relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByIdWithRelations:objectId relations:relations];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:objectId relations:relations relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByEntity:entity];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByEntity:entity relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByEntityWithRelations:entity relations:relations];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByEntity:entity relations:relations relationsDepth:relationsDepth];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(NSDictionary<NSString*,id> *)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loadRelations:entity relations:relations];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}


// async methods with responder

-(id)onResponse:(id)result {
    return [result isKindOfClass:NSDictionary.class]?result:[Types propertyDictionary:result];
}

-(void)save:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_SAVE args:args responder:_responder];
}

-(void)remove:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_REMOVE args:args responder:_responder];
}

-(void)findResponder:(id <IResponder>)responder {
    [self find:BACKENDLESS_DATA_QUERY responder:responder];
}

-(id)setCollectionFields:(ResponseContext *)response {
    
    BackendlessCollection *bc = response.response;
    BackendlessDataQuery *dataQuery = response.context;
    [bc pageSize:dataQuery.queryOptions.pageSize.integerValue];
    bc.query = dataQuery;
    bc.tableName = _tableName;
    return [self fixClassCollection:bc];
}

-(void)find:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, dataQuery?dataQuery:BACKENDLESS_DATA_QUERY];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(setCollectionFields:) selErrorHandler:nil];
    _responder.context = dataQuery;
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIND args:args responder:_responder];
}

-(void)findFirstResponder:(id <IResponder>)responder {
   
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args responder:_responder];
}

-(void)findFirst:(int)relationsDepth responder:(id <IResponder>)responder {
    [self findFirst:@[] relationsDepth:relationsDepth responder:responder];
}

-(void)findFirstWithRelations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder {
    [self findFirst:relations relationsDepth:0 responder:responder];
}

-(void)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, relations?relations:@[], @(relationsDepth)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FIRST args:args responder:_responder];
}

-(void)findLastResponder:(id <IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args responder:_responder];
}

-(void)findLast:(int)relationsDepth responder:(id <IResponder>)responder {
    [self findLast:@[] relationsDepth:relationsDepth responder:responder];
}

-(void)findLastWithRelations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder {
    [self findLast:relations relationsDepth:0 responder:responder];
}

-(void)findLast:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, relations?relations:@[], @(relationsDepth)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LAST args:args responder:_responder];
}

-(void)findById:(NSString *)objectId responder:(id <IResponder>)responder {
    [self findByIdWithRelations:objectId relations:@[] responder:responder];
}

-(void)findById:(NSString *)objectId relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    [self findById:objectId relations:@[] relationsDepth:relationsDepth responder:responder];
}

-(void)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder {
    
    if (!objectId)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, objectId, relations?relations:@[]];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args responder:_responder];
}

-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!objectId)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, objectId, relations?relations:@[], @(relationsDepth)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args responder:_responder];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity responder:(id <IResponder>)responder {
    [self findByEntity:entity relations:@[] relationsDepth:0 responder:responder];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    [self findByEntity:entity relations:@[] relationsDepth:relationsDepth responder:responder];
}

-(void)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder {
    [self findByEntity:entity relations:relations relationsDepth:0 responder:responder];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity, relations?relations:@[], @(relationsDepth)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_FINDBYID args:args responder:_responder];
}

-(id)addLodedRelations:(ResponseContext *)response {
    
    NSDictionary<NSString*,id> *relations = (NSDictionary<NSString*,id> *)response.response;
    NSDictionary<NSString*,id> *result = [response.context isKindOfClass:NSDictionary.class]?response.context:[Types propertyDictionary:response.context];
    NSMutableDictionary<NSString*,id> *entityWithRel = [NSMutableDictionary dictionaryWithDictionary:result];
    [entityWithRel addEntriesFromDictionary:relations];
    return [NSDictionary dictionaryWithDictionary:entityWithRel];
}

-(void)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _tableName, entity, relations?relations:@[]];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(addLodedRelations:) selErrorHandler:nil];
    _responder.context = entity;
    _responder.chained = responder;
    [invoker invokeAsync:_SERVER_PERSISTENCE_SERVICE_PATH method:_METHOD_LOAD args:args responder:_responder];
}


// async methods with block-based callbacks
-(void)save:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self find:dataQuery responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirstResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirst:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirstWithRelations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirstWithRelations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findFirst:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findFirst:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLastResponder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLast:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLastWithRelations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLastWithRelations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findLast:(NSArray<NSString *>*)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findLast:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectId response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectId relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectId relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByIdWithRelations:(NSString *)objectId relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByIdWithRelations:objectId relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectId relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectId relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByEntity:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByEntity:entity relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByEntityWithRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByEntityWithRelations:entity relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByEntity:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations relationsDepth:(int)relationsDepth response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByEntity:entity relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loadRelations:(NSDictionary<NSString*,id> *)entity relations:(NSArray<NSString*> *)relations response:(void(^)(NSDictionary<NSString*,id> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loadRelations:entity relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
