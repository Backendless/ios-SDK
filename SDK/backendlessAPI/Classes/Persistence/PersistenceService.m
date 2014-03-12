//
//  PersistenceService.m
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

#import "PersistenceService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
//#import "ResponderBlocksContext.h"
#import "HashMap.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessCollection.h"
#import "ObjectProperty.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "BackendlessEntity.h"
#import "DataStoreFactory.h"
#import <objc/runtime.h>
#import "BackendlessCache.h"
#import "OfflineModeManager.h"


#define FAULT_NO_ENTITY [Fault fault:@"Entity is not valid"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"Object ID is not exist"]

// SERVICE NAME
static NSString *SERVER_PERSISTENCE_SERVICE_PATH = @"com.backendless.services.persistence.PersistenceService";
// METHOD NAMES
static NSString *METHOD_CREATE = @"create";
static NSString *METHOD_UPDATE = @"update";
static NSString *METHOD_REMOVE = @"remove";
static NSString *METHOD_FINDBYID = @"findById";
static NSString *METHOD_DESCRIBE = @"describe";
static NSString *METHOD_FIND = @"find";
static NSString *METHOD_FIRST = @"first";
static NSString *METHOD_LAST = @"last";
static NSString *METHOD_LOAD = @"loadRelations";
NSString *LOAD_ALL_RELATIONS = @"*";
@interface PersistenceService()
- (id)setCurrentPageSize:(id)collection;
//- (id)responseManagedObject:(id)object;
- (id)loadRelations:(id)response;
-(BOOL)prepareClass:(Class) className;
-(BOOL)prepareObject:(id) object;
-(NSDictionary *)filteringProperty:(id)object;
-(id)failWithOfflineMode:(Fault *)error;

@end

@implementation PersistenceService

-(id)init {
	if ( (self=[super init]) ) {
        
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.ObjectProperty" mapped:[ObjectProperty class]];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PersistenceService"];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// sync methods

-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault
{
    id result = [self save:entityName entity:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault
{
    id result = [self update:entityName entity:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)save:(id)entity error:(Fault **)fault
{
    id result = [self save:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)create:(id)entity error:(Fault **)fault
{
    id result = [self create:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)update:(id)entity error:(Fault **)fault
{
    id result = [self update:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)remove:(Class)entity sid:(NSString *)sid error:(Fault **)fault
{
    id result = [self remove:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BOOL)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault
{
    [self removeAll:entity dataQuery:dataQuery];
//    if ([result isKindOfClass:[Fault class]]) {
//        (*fault) = result;
//        return nil;
//    }
    return YES;
}
-(id)findById:(NSString *)entityName sid:(NSString *)sid error:(Fault **)fault
{
    id result = [self findById:entityName sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)findByClassId:(Class)entity sid:(NSString *)sid error:(Fault **)fault
{
    id result = [self findByClassId:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault
{
    id result = [self find:entity dataQuery:dataQuery];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)first:(Class)entity error:(Fault **)fault
{
    id result = [self first:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)last:(Class)entity error:(Fault **)fault
{
    id result = [self last:entity];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)describe:(NSString *)classCanonicalName error:(Fault **)fault
{
    id result = [self describe:classCanonicalName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations error:(Fault **)fault
{
    id result = [self findById:entityName sid:sid relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(id)load:(id)object relations:(NSArray *)relations error:(Fault **)fault
{
    id result = [self load:object relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}



-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity {
    
    if (!entity || !entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
//    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    return result;
}

-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid {
    
    if (!entity || !entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
//    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    return result;
}

-(id)save:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    NSDictionary *props = [Types propertyDictionary:entity];
    [DebLog log:@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PersistenceService -> save: %@", props];
    NSString *objectId = (props) ? [props objectForKey:PERSIST_OBJECT_ID] : nil;
    
    return (objectId && ![objectId isKindOfClass:[NSNull class]]) ? [backendless.persistenceService update:entity] : [backendless.persistenceService create:entity];
}

-(id)create:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];

    [DebLog log:@"PersistenceService -> create: class = %@, entity = %@", [Types objectClassName:entity], entity];
    NSDictionary *props = [self filteringProperty:entity];
    [self prepareObject:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types objectClassName:entity], props, nil];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    BackendlessEntity *tempEntity = result;
    ((BackendlessEntity *)entity).objectId = tempEntity.objectId;
    return result;
}

-(id)update:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];

    [DebLog log:@"PersistenceService -> update: class = %@, entity = %@", [Types objectClassName:entity], entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types objectClassName:entity], props, nil];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    return result;
}

-(NSNumber *)remove:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
}

-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    BackendlessCollection *bc = [backendless.persistenceService find:entity dataQuery:dataQuery];
    [bc removeAll];
    
    [DebLog log:@"PersistenceService -> removeAll: totalObjects = %@", bc.totalObjects];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];

    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByClassId:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], dataQuery, nil];
    id result = [backendlessCache invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args];
    if (![result isKindOfClass:[Fault class]])
    {
        BackendlessCollection *bc = result;
        [bc pageSize:dataQuery.queryOptions.pageSize.integerValue];
        bc.backendlessQuery = dataQuery;
        return bc;
    }
    else
        return result;
    
}

-(id)first:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args];
}

-(id)last:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args];
}

-(NSArray *)describe:(NSString *)classCanonicalName {
    
    if (!classCanonicalName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, classCanonicalName, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSDictionary *)relations
{
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)load:(BackendlessEntity *)object relations:(NSArray *)relations
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:[object class]], object.objectId, relations, nil];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]])
    {
        return result;
    }
    NSArray *keys = [result allKeys];
    for(NSString *propertyName in keys)
    {
        [object setValue:[result valueForKey:propertyName] forKey:propertyName];
    }
    return object;
}


// async methods with responder

-(void)save:(NSString *)entityName entity:(NSDictionary *)entity responder:(id <IResponder>)responder {
    
    if (!entity || !entityName) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode)
    {
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = responder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:responder];
}

-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entity || !entityName) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid) 
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode)
    {
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = responder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:responder];
}

-(void)save:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    NSDictionary *props = [Types propertyDictionary:entity];
    NSString *objectId = (props) ? [props objectForKey:PERSIST_OBJECT_ID] : nil;
    if (objectId && ![objectId isKindOfClass:[NSNull class]])
        [backendless.persistenceService update:entity responder:responder];
    else
        [backendless.persistenceService create:entity responder:responder];
}

-(void)create:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareObject:entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types objectClassName:entity], props, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode)
    {
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = responder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:responder];
}

-(void)update:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types objectClassName:entity], props, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode)
    {
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = responder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:responder];
}

-(void)remove:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid) 
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:responder];
}

-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    [self removeAll:entity dataQuery:dataQuery
           response:^(BackendlessCollection *bc) {
               [responder responseHandler:bc];
    }
              error:^(Fault *fault) {
                  [responder errorHandler:fault];
              }
     ];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entityName) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid) 
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByClassId:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid) 
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], dataQuery, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(setCurrentPageSize:) selErrorHandler:nil];
    _responder.context = dataQuery;
    _responder.chained = responder;
    
    [backendlessCache invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responder:_responder];
}

-(void)first:(Class)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:responder];
}

-(void)last:(Class)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:responder];
}

-(void)describe:(NSString *)classCanonicalName responder:(id <IResponder>)responder {
    
    if (!classCanonicalName) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, classCanonicalName, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args responder:responder];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations responder:(id<IResponder>)responder
{
    if (!entityName)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)load:(BackendlessEntity *)object relations:(NSArray *)relations responder:(id<IResponder>)responder
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [Types typeClassName:[object class]], object.objectId, relations, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(loadRelations:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = @{@"object":object, @"relations":relations};
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args responder:_responder];

}

// async methods with block-base callbacks

-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entityName entity:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self update:entityName entity:entity sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self save:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self create:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self update:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(Class)entity sid:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:entity sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    [backendless.persistenceService
     find:entity dataQuery:dataQuery
     response:^(BackendlessCollection *bc) {
         
         [DebLog log:@"PersistenceService -> removeAll: totalObjects = %@", bc.totalObjects];
         
         [bc removeAll:responseBlock error:errorBlock];
     }
     error:^(Fault *fault) {
         [DebLog logY:@"PersistenceService -> removeAll: FAULT: %@ <%@>\n %@", fault.faultCode, fault.message, fault.detail];
         errorBlock(fault);
     }
     ];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:entityName sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByClassId:(Class)entity sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByClassId:entity sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self find:entity dataQuery:dataQuery responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)first:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self first:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)last:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self last:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self describe:classCanonicalName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:entityName sid:sid relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self load:object relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// IDataStore class factory

-(id <IDataStore>)of:(Class)entityClass {
    return [DataStoreFactory createDataStore:entityClass];
}

// utilites
-(NSDictionary *)getObjectMetadata:(id)object {    
    
    const NSString *metadataKeys = @",___class,__meta,created,objectId,updated,";
    
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    NSDictionary *props = [Types propertyDictionary:object];
    NSArray *keys = [props allKeys];
    for (NSString *key in keys) {
        NSRange rang = [metadataKeys rangeOfString:[NSString stringWithFormat:@",%@,",key]];
        if (rang.length) {
            id obj = [props valueForKey:key];
            if (obj) {
                [metadata setObject:obj forKey:key];
            }
        }
    }
    
    return metadata;
}

/*/
-(void)removeAllSync:(Class)entity {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    BackendlessCollection *bc = [backendless.persistenceService find:entity dataQuery:nil];
    
    [DebLog log:@"PersistenceService -> removeAllSync: totalObjects = %@", bc.totalObjects];
    
    int count = 0;
    while (YES) {
        
        for (id obj in bc.data) {
            [backendless.persistenceService remove:entity sid:[obj valueForKey:PERSIST_OBJECT_ID]];
        }
        
        count += bc.data.count;
        if (count < bc.valTotalObjects) {
            [bc nextPage];
            continue;
        }
        
        break;
    }    
}
/*/ 

/*/
-(void)removeAllPagesAsync:(BackendlessCollection *)bc {
    
    for (id obj in bc.data) {
        [backendless.persistenceService
         remove:[obj class] sid:[obj valueForKey:PERSIST_OBJECT_ID]
         response:^(NSNumber *num) {
         }
         error:^(Fault *fault) {
             [DebLog logY:@"PersistenceService -> removeAllPagesAsync: FAULT: %@ <%@>\n %@", fault.faultCode, fault.message, fault.detail];
         }
         ];
    }
    
    if (([bc valOffset] + bc.data.count) < bc.valTotalObjects) {
        [bc nextPageAsync:^(BackendlessCollection *bc) {
                     [self removeAllPagesAsync:bc];
                 }
                    error:^(Fault *fault) {
                        [DebLog logY:@"PersistenceService -> removeAllPagesAsync: FAULT: %@ <%@>\n %@", fault.faultCode, fault.message, fault.detail];
                    }
         ];
    }
}
/*/ 

#pragma mark -
#pragma mark Private Methods
-(NSDictionary *)filteringProperty:(id)object
{
    NSDictionary *properties = [Types propertyDictionary:object];
    NSMutableDictionary *result= [NSMutableDictionary dictionaryWithDictionary:properties];
//    [result removeObjectForKey:@"__meta"];
    
    return result;
}
/*/
void set_meta(id self, SEL _cmd, id value)
{
    objc_setAssociatedObject(self, @selector(backendlessMeta), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
id get_meta(id self, SEL _cmd)
{
    return objc_getAssociatedObject(self, @selector(backendlessMeta));
}

void set_object_id(id self, SEL _cmd, id value)
{
    objc_setAssociatedObject(self, @selector(backendlessObjectId), value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
id get_object_id(id self, SEL _cmd)
{
    return objc_getAssociatedObject(self, @selector(backendlessObjectId));
}
-(BOOL)prepareClass:(Class)className
{
    Class cl = [className class];
    if (!class_getProperty(className, "objectId"))
    {
        class_addProperty(cl, "objectId", nil, 0);
        class_addMethod(cl, @selector(setObjectId:), (IMP)set_object_id, "v@:@");
        class_addMethod(cl, @selector(objectId), (IMP)get_object_id, "@@:");
    }
    
    if (!class_getProperty(className, "__meta"))
    {
        class_addProperty(cl, "__meta", nil, 0);
        class_addMethod(cl, @selector(set__meta:), (IMP)set_meta, "v@:@");
        class_addMethod(cl, @selector(__meta), (IMP)get_meta, "@@:");
    }
    return YES;
}

// 
-(BOOL)prepareObject:(id)object
{
    if([self prepareClass:[object class]])
    {
        [object setValue:nil forKey:PERSIST_OBJECT_ID];
        [object setValue:nil forKey:@"__meta"];
        
        return YES;
    }
    return NO;
}
/*/

//
-(BOOL)prepareClass:(Class)className {
    id object = [Types classInstance:className];
    return [object resolveProperty:PERSIST_OBJECT_ID] && [object resolveProperty:@"__meta"];
}
// 

-(BOOL)prepareObject:(id)object {
    return [object resolveProperty:PERSIST_OBJECT_ID value:nil] && [object resolveProperty:@"__meta" value:nil];
}

- (id)setCurrentPageSize:(id)response
{
    BackendlessDataQuery *dataQuery = ((ResponseContext *)response).context;
    BackendlessCollection *collection = ((ResponseContext *)response).response;
    collection.backendlessQuery = dataQuery;
    [collection pageSize:dataQuery.queryOptions.pageSize.integerValue];
    
    return collection;
}

-(id)loadRelations:(ResponseContext *)response
{
    
    NSArray *relations = [response.context valueForKey:@"relations"];
    BackendlessEntity *object = [response.context valueForKey:@"object"];
    id result = response.response;
    for(NSString *propertyName in relations)
    {
        if ([[result valueForKey:propertyName] isKindOfClass:[NSNull class]]) {
            continue;
        }
        [object setValue:[result valueForKey:propertyName] forKey:propertyName];
    }
    return object;
}

-(id)failWithOfflineMode:(Fault *)error
{
    Responder *responder = error.context;
    id res = [[OfflineModeManager sharedInstance] saveObject:responder.context];
    [responder.chained responseHandler:res];
    responder.chained = nil;
    return nil;
}
@end
