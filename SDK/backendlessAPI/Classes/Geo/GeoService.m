//
//  GeoService.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "GeoService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessGeoQuery.h"
#import "ProtectedBackendlessGeoQuery.h"
#import "LocationTracker.h"
#import "GeoFence.h"
#import "GeoFenceMonitoring.h"
#import "ICallback.h"
#import "ServerCallback.h"
#import "ClientCallback.h"
#import "VoidResponseWrapper.h"

#define FAULT_GEO_POINT_IS_NULL [Fault fault:@"Geo point is NULL" detail:@"Unable to operate with geo point. GeoPoint is NULL" faultCode:@"4000"]
#define FAULT_CATEGORY_NAME_IS_NULL [Fault fault:@"Category name is NULL" detail:@"Cannot add category. Category name is NULL" faultCode:@"4005"]
#define FAULT_CATEGORY_NAME_IS_EMPTY [Fault fault:@"Category name is empty" detail:@"Cannot add category. Category name is empty" faultCode:@"4006"]
#define FAULT_CATEGORY_NAME_IS_DEFAULT [Fault fault:@"Category name is 'Default'" detail:@"Cannot add category. Category name is 'Default'" faultCode:@"4007"]
#define FAULT_REMOVE_CATEGORY_NAME_IS_NULL [Fault fault:@"Category name is NULL" detail:@"Cannot remove category. Category name is NULL" faultCode:@"4015"]
#define FAULT_REMOVE_CATEGORY_NAME_IS_EMPTY [Fault fault:@"Category name is empty" detail:@"Cannot remove category. Category name is empty" faultCode:@"4016"]
#define FAULT_REMOVE_CATEGORY_NAME_IS_DEFAULT [Fault fault:@"Category name is 'Default'" detail:@"Cannot remove category. Category name is 'Default'" faultCode:@"4017"]
#define FAULT_GEO_POINT_ID_IS_NULL [Fault fault:@"Geo point ID is NULL" detail:@"Unable to operate with geo point. GeoPoint ID is NULL" faultCode:@"4900"]
#define FAULT_GEO_FENCE_NAME_IS_NULL [Fault fault:@"Geo fence name is NULL"  detail:@"Unable to operate with geo fence. GeoFence is NULL" faultCode:@"4901"]
#define FAULT_CALLBACK_IS_INVALID [Fault fault:@"Callback instance is not valid" detail:@"Callback instance is not valid" faultCode:@"4902"]
#define FAULT_GEO_QUERY_IS_NULL [Fault fault:@"Geo query is NULL" detail:@"Unable to operate with geo query. GeoQuery is NULL" faultCode:@"4903"]

static NSString *SERVER_GEO_SERVICE_PATH = @"com.backendless.services.geo.GeoService";
static NSString *METHOD_ADD_CATEGORY = @"addCategory";
static NSString *METHOD_DELETE_CATEGORY = @"deleteCategory";
static NSString *METHOD_ADD_POINT = @"addPoint";
static NSString *METHOD_UPDATE_POINT = @"updatePoint";
static NSString *METHOD_GET_CATEGORIES = @"getCategories";
static NSString *METHOD_GET_POINTS = @"getPoints";
static NSString *METHOD_GET_POINTS_WITH_MATCHES = @"relativeFind";
static NSString *METHOD_DELETE_GEOPOINT = @"removePoint";
static NSString *METHOD_LOAD_METADATA = @"loadMetadata";
static NSString *METHOD_LOAD_GEOPOINTS = @"loadGeoPoints";
static NSString *METHOD_RUN_ON_ENTER_ACTION = @"runOnEnterAction";
static NSString *METHOD_RUN_ON_STAY_ACTION = @"runOnStayAction";
static NSString *METHOD_RUN_ON_EXIT_ACTION = @"runOnExitAction";
static NSString *METHOD_GET_FENCE = @"getFence";
static NSString *METHOD_GET_FENCES = @"getFences";
static NSString *METHOD_COUNT = @"count";

@interface GeoService ()

-(Fault *)isFaultAddCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder;
-(Fault *)isFaultRemoveCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder;
-(Fault *)isFaultGeoPoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder;
-(Fault *)isFaultGeoPointId:(NSString *)pointId responder:(id <IResponder>)responder;
-(Fault *)isFaultGeoFenceName:(NSString *)geoFenceName responder:(id <IResponder>)responder;
-(id)getResponse:(ResponseContext *)response;
-(id)getMetadata:(ResponseContext *)response;
-(id)getError:(id)error;

@end

@implementation GeoService

-(id)init {
    if (self = [super init]) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoCategory" mapped:[GeoCategory class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoCluster" mapped:[GeoCluster class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.BackendlesGeoQuery" mapped:[BackendlessGeoQuery class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.SearchMatchesResult" mapped:[SearchMatchesResult class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.NSArray" mapped:[NSArray class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geofence.model.GeoFenceAMF" mapped:[GeoFence class]];
        _presence = [Presence new];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC GeoService"];
    [_presence release];
    [super dealloc];
}

// sync methods with fault return (as exception)

-(GeoCategory *)addCategory:(NSString *)categoryName {
    id fault = [self isFaultAddCategoryName:categoryName responder:nil];
    if (fault)
        return [backendless throwFault:fault];
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:fault];
    }
    return result;
}

-(NSNumber *)deleteCategory:(NSString *)categoryName {
    id fault = [self isFaultRemoveCategoryName:categoryName responder:nil];
    if (fault)
        return [backendless throwFault:fault];
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:fault];
    }
    return result;
}

-(id)savePoint:(GeoPoint *)geoPoint {
    id fault = [self isFaultGeoPoint:geoPoint responder:nil];
    if (fault)
        return [backendless throwFault:fault];
    NSArray *args = [NSArray arrayWithObjects:geoPoint, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:fault];
    }
    return result;
}

-(NSArray<GeoCategory *> *)getCategories {
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:@[]];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSArray<GeoPoint *> *)getPoints:(BackendlessGeoQuery *)query {
    NSArray *args = [NSArray arrayWithObjects:query, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    if (![result isKindOfClass:[NSArray class]]) {
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    NSArray<GeoPoint *> *collection = result;
    [self setReferenceToCluster:collection geoQuery:query];
    return collection;
}

-(NSArray<GeoPoint *> *)getClusterPoints:(GeoCluster *)geoCluster {
    NSArray *args = @[geoCluster.objectId, geoCluster.geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    if (![result isKindOfClass:[NSArray class]]) {
        NSLog(@"GeoService->getCluster: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    NSArray<GeoPoint *> *collection = result;
    return collection;
}

-(NSArray<GeoPoint *> *)getFencePoints:(NSString *)geoFenceName {
    id result = [self getFencePoints:geoFenceName query:nil];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSArray<GeoPoint *> *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return [backendless throwFault:fault];
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoFenceName, geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    if (![result isKindOfClass:[NSArray class]]) {
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    NSArray<GeoPoint *> *collection = result;
    [self setReferenceToCluster:collection geoQuery:query];
    return collection;
}

-(NSArray *)relativeFind:(BackendlessGeoQuery *)query {
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    NSArray<GeoPoint *> *collection = result;
    [self setReferenceToCluster:collection geoQuery:query];
    return collection;
}

-(void)setReferenceToCluster:(NSArray<GeoPoint *> *)collection geoQuery:(BackendlessGeoQuery *)geoQuery {
    BackendlessGeoQuery *protectedQuery = [[ProtectedBackendlessGeoQuery alloc] initWithQuery:geoQuery];
    for (GeoPoint *geoPoint in collection) {
        if ([geoPoint isKindOfClass:[GeoCluster class]]) {
            [(GeoCluster *)geoPoint setGeoQuery:protectedQuery];
        }
    }
}

-(void)removePoint:(GeoPoint *)geoPoint {
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        [backendless throwFault:fault];
    NSArray *args = @[geoPoint.objectId];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        [backendless throwFault:fault];
    }
    return;
}

-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint {
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        return [backendless throwFault:fault];;
    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[geoPoint.objectId, query];
    [geoPoint metadata:[invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args]];
    return geoPoint;
}

-(NSNumber *)runOnEnterAction:(NSString *)geoFenceName {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return [backendless throwFault:fault];;
    NSArray *args = @[geoFenceName];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return [backendless throwFault:fault];
    NSArray *args = @[geoFenceName, geoPoint];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)runOnStayAction:(NSString *)geoFenceName {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return [backendless throwFault:fault];
    NSArray *args = @[geoFenceName];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return [backendless throwFault:fault];
    NSArray *args = @[geoFenceName, geoPoint];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)runOnExitAction:(NSString *)geoFenceName {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return [backendless throwFault:fault];
    NSArray *args = @[geoFenceName];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return [backendless throwFault:fault];
    NSArray *args = @[geoFenceName, geoPoint];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)getGeopointCount:(BackendlessGeoQuery *)query {
    if (!query)
        return [backendless throwFault:FAULT_GEO_QUERY_IS_NULL];
    NSArray *args = @[query];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

-(NSNumber *)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query {
    if (!geoFenceName || !geoFenceName.length)
        return [backendless throwFault:FAULT_GEO_FENCE_NAME_IS_NULL];
    if (!query)
        return [backendless throwFault:FAULT_GEO_QUERY_IS_NULL];
    NSArray *args = @[geoFenceName, query];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return [backendless throwFault:result];
    }
    return result;
}

// async methods with block-based callbacks

-(void)addCategory:(NSString *)categoryName response:(void(^)(GeoCategory *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultAddCategoryName:categoryName responder:responder])
        return;
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args responder:responder];
}

-(void)deleteCategory:(NSString *)categoryName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultRemoveCategoryName:categoryName responder:responder])
        return;
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args responder:responder];
}

-(void)savePoint:(GeoPoint *)geoPoint response:(void(^)(GeoPoint *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoPoint:geoPoint responder:responder])
        return;
    NSArray *args = [NSArray arrayWithObjects:geoPoint, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args responder:responder];
}

-(void)getCategories:(void(^)(NSArray<GeoCategory *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:@[] responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSArray *args = [NSArray arrayWithObjects:query, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)getClusterPoints:(GeoCluster *)geoCluster response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSArray *args = @[geoCluster.objectId, geoCluster.geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoCluster.geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args responder:_responder];
}

-(void)getFencePoints:(NSString *)geoFenceName response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFencePoints:geoFenceName query:nil response:responseBlock error:errorBlock];
}

-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSArray<GeoPoint *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoFenceName, geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args responder:_responder];
}

-(void)removePoint:(GeoPoint *)geoPoint response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock];
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;
    NSArray *args = [NSArray arrayWithObjects:geoPoint.objectId, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args responder:responder];
}

-(void)loadMetadata:(GeoPoint *)geoPoint response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;
    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[geoPoint.objectId, query];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getMetadata:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoPoint;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args responder:_responder];
}

-(void)runOnEnterAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args responder:responder];
}

-(void)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args responder:responder];
}

-(void)runOnStayAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args responder:responder];
}

-(void)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args responder:responder];
}

-(void)runOnExitAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args responder:responder];
}

-(void)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args responder:responder];
}

-(void)getGeopointCount:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!query)
        return [responder errorHandler:FAULT_GEO_QUERY_IS_NULL];
    NSArray *args = @[query];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

-(void)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!geoFenceName || !geoFenceName.length)
        return [responder errorHandler:FAULT_GEO_FENCE_NAME_IS_NULL];
    if (!query)
        return [responder errorHandler:FAULT_GEO_QUERY_IS_NULL];
    NSArray *args = @[geoFenceName, query];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

// utilites

-(GEO_RECT)geoRectangle:(GEO_POINT)center length:(double)length width:(double)width {
    GEO_RECT rect;
    double value =  center.latitude + width/2;
    
    rect.nordWest.latitude = (value > 90.0) ? 180.0 - value : value;
    value =  center.longitude - length/2;
    rect.nordWest.longitude = (value < -180.0) ? 360.0 + value : value;
    
    value =  center.latitude - width/2;
    rect.southEast.latitude = (value < -90.0) ? -(value + 180.0) : value;
    value =  center.longitude + length/2;
    rect.southEast.longitude = (value > 180.0) ? value - 360.0 : value;
    
    return rect;
}

-(void)startGeofenceMonitoring:(id <IGeofenceCallback>)callback responder:(id <IResponder>)responder {
    [self startGeofenceMonitoringCallback:[ClientCallback callback:callback] responder:responder];
}

-(void)startGeofenceMonitoringGeoPoint:(GeoPoint *)geoPoint response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    [self startGeofenceMonitoringCallback:[ServerCallback callback:geoPoint] responder:[ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock]];
}

-(void)startGeofenceMonitoring:(id <IGeofenceCallback>)callback response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    [self startGeofenceMonitoringCallback:[ClientCallback callback:callback] responder:[ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock]];
}

-(void)startGeofenceMonitoringGeoPoint:(NSString *)geofenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    [self startGeofenceMonitoringCallback:[ServerCallback callback:geoPoint] name:geofenceName responder:[ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock]];
}

-(void)startGeofenceMonitoring:(NSString *)geofenceName callback:(id <IGeofenceCallback>)callback response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock {
    [self startGeofenceMonitoringCallback:[ClientCallback callback:callback] name:geofenceName responder:[ResponderBlocksContext responderBlocksContext:[voidResponseWrapper wrapResponseBlock:responseBlock] error:errorBlock]];
}

-(void)stopGeofenceMonitoring {
    GeoFenceMonitoring *monitoring = [GeoFenceMonitoring sharedInstance];
    [monitoring removeGeoFences];
    [[LocationTracker sharedInstance] removeListener:[monitoring listenerName]];
}

-(void)stopGeofenceMonitoring:(NSString *)geofenceName {
    GeoFenceMonitoring *monitoring = [GeoFenceMonitoring sharedInstance];
    [monitoring removeGeoFence:geofenceName];
    if (![monitoring isMonitoring]) {
        [[LocationTracker sharedInstance] removeListener:[monitoring listenerName]];
    }
}

-(void)startGeofenceMonitoringCallback:(id <ICallback>)callback responder:(id <IResponder>)responder {
    if ([self isFaultCallbackIsInvalid:callback responder:responder])
        return;
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getGeoFences:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = callback;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_FENCES args:@[] responder:_responder];
}

-(void)startGeofenceMonitoringCallback:(id <ICallback>)callback name:(NSString *)geofenceName responder:(id <IResponder>)responder {
    if ([self isFaultGeoFenceName:geofenceName responder:responder] || [self isFaultCallbackIsInvalid:callback responder:responder])
        return;
    NSArray *args = @[geofenceName];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getGeoFences:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = callback;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_FENCE args:args responder:_responder];
}

-(void)addFenceMonitoring:(id <ICallback>)callback geoFences:(id)geoFences {
    [DebLog log:@"GeoService -> addFenceMonitoring: callback = %@, geoFences = %@", callback, geoFences];
    @try {
        GeoFenceMonitoring *monitiring = [GeoFenceMonitoring sharedInstance];
        if ([geoFences isKindOfClass:GeoFence.class])
            [monitiring addGeoFence:geoFences callback:callback];
        else
            if ([geoFences isKindOfClass:NSArray.class])
                [monitiring addGeoFences:geoFences callback:callback];
            else {
                [DebLog logY:@"GeoService -> addFenceMonitoring: (ERROR) Illegal class in response: %@", geoFences];
                return;
            }
        LocationTracker *locationTracker = [LocationTracker sharedInstance];
        NSString *listenerName = [monitiring listenerName];
        if (![locationTracker isContainListener:listenerName]) {
            [DebLog log:@"GeoService -> addFenceMonitoring: add listener = %@", listenerName];
            [locationTracker addListener:listenerName listener:monitiring];
            [locationTracker startLocationManager];
        }
    }
    @catch (Fault *fault) {
        [DebLog logY:@"GeoService -> addFenceMonitoring: (FAULT) %@", fault];
    }
}

-(Fault *)isFaultAddCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder {
    Fault *fault = (!categoryName) ? FAULT_CATEGORY_NAME_IS_NULL : (!categoryName.length) ? FAULT_CATEGORY_NAME_IS_EMPTY :
    ([categoryName isEqualToString:DEFAULT_CATEGORY_NAME]) ? FAULT_CATEGORY_NAME_IS_DEFAULT : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(Fault *)isFaultRemoveCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder {
    Fault *fault = (!categoryName) ? FAULT_REMOVE_CATEGORY_NAME_IS_NULL : (!categoryName.length) ? FAULT_REMOVE_CATEGORY_NAME_IS_EMPTY :
    ([categoryName isEqualToString:DEFAULT_CATEGORY_NAME]) ? FAULT_REMOVE_CATEGORY_NAME_IS_DEFAULT : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(Fault *)isFaultGeoPoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder {
    Fault *fault = (!geoPoint) ? FAULT_GEO_POINT_IS_NULL : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(Fault *)isFaultGeoPointId:(NSString *)pointId responder:(id <IResponder>)responder {
    Fault *fault = (!pointId || !pointId.length) ? FAULT_GEO_POINT_ID_IS_NULL : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(Fault *)isFaultGeoFenceName:(NSString *)geoFenceName responder:(id <IResponder>)responder {
    Fault *fault = (!geoFenceName || !geoFenceName.length) ? FAULT_GEO_FENCE_NAME_IS_NULL : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(Fault *)isFaultCallbackIsInvalid:(id)callback responder:(id <IResponder>)responder {
    Fault *fault = (!callback || ![callback conformsToProtocol:@protocol(ICallback)]) ? FAULT_CALLBACK_IS_INVALID : nil;
    if (fault)
        responder ? [responder errorHandler:fault] : [backendless throwFault:fault];
    return fault;
}

-(id)getResponse:(ResponseContext *)response {
    NSArray<GeoPoint *> *collection = response.response;
    BackendlessGeoQuery *geoQuery = response.context;
    [self setReferenceToCluster:collection geoQuery:geoQuery];
    return collection;
}

-(id)getMetadata:(ResponseContext *)response {
    NSDictionary *metadata = response.response;
    GeoPoint *geoPoint = response.context;
    [geoPoint metadata:metadata];
    return geoPoint;
}

-(id)getGeoFences:(ResponseContext *)response {
    id geoFences = response.response;
    id <ICallback> callback = response.context;
    [self addFenceMonitoring:callback geoFences:geoFences];
    return nil;
}

-(id)getError:(id)error {
    return error;
}

@end
