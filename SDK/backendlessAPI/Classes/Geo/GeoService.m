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

#import "GeoService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessGeoQuery.h"
#import "LocationTracker.h"
#import "GeoFence.h"
#import "GeoFenceMonitoring.h"
#import "ICallback.h"
#import "ServerCallback.h"
#import "ClientCallback.h"

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

// SERVICE NAME
static NSString *SERVER_GEO_SERVICE_PATH = @"com.backendless.services.geo.GeoService";
// METHOD NAMES
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
	if ( (self=[super init]) ) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoCategory" mapped:[GeoCategory class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoCluster" mapped:[GeoCluster class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.BackendlesGeoQuery" mapped:[BackendlessGeoQuery class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.SearchMatchesResult" mapped:[SearchMatchesResult class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.NSArray" mapped:[NSArray class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geofence.model.GeoFenceAMF" mapped:[GeoFence class]];
#if !_IS_USERS_CLASS_
        [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
#endif
        
        _presence = [Presence new];
	
    }
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC GeoService"];
    
    [_presence release];
    	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// sync methods with fault option

#if OLD_ASYNC_WITH_FAULT

-(GeoCategory *)addCategory:(NSString *)categoryName error:(Fault **)fault {
    
    id result = [self addCategory:categoryName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)deleteCategory:(NSString *)categoryName error:(Fault **)fault {
    
    id result = [self deleteCategory:categoryName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(GeoPoint *)savePoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self savePoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray<NSString *> *)getCategoriesError:(Fault **)fault {
    
    id result = [self getCategories];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray *)getPoints:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self getPoints:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray *)getClusterPoints:(GeoCluster *)geoCluster error:(Fault **)fault {
    
    id result = [self getClusterPoints:geoCluster];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray *)getFencePoints:(NSString *)geoFenceName error:(Fault **)fault {
    return [self getFencePoints:geoFenceName query:nil error:fault];
}

-(NSArray *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self getFencePoints:geoFenceName query:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray *)relativeFind:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self relativeFind:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)removePoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self removePoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self loadMetadata:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)runOnEnterAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = [self runOnEnterAction:geoFenceName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self runOnEnterAction:geoFenceName geoPoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)runOnStayAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = [self runOnStayAction:geoFenceName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self runOnStayAction:geoFenceName geoPoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)runOnExitAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = [self runOnExitAction:geoFenceName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = [self runOnExitAction:geoFenceName geoPoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
#else

#if 0 // wrapper for work without exception

id result = nil;
@try {
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

-(GeoCategory *)addCategory:(NSString *)categoryName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self addCategory:categoryName];
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

-(BOOL)deleteCategory:(NSString *)categoryName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self deleteCategory:categoryName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(GeoPoint *)savePoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self savePoint:geoPoint];
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

-(NSArray<NSString *> *)getCategoriesError:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getCategories];
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

-(NSArray *)getPoints:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getPoints:query];
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

-(NSArray *)getClusterPoints:(GeoCluster *)geoCluster error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getClusterPoints:geoCluster];
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

-(NSArray *)getFencePoints:(NSString *)geoFenceName error:(Fault **)fault {
    return [self getFencePoints:geoFenceName query:nil error:fault];
}

-(NSArray *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getFencePoints:geoFenceName query:query];
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

-(NSArray *)relativeFind:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self relativeFind:query];
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

-(BOOL)removePoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self removePoint:geoPoint];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loadMetadata:geoPoint];
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

-(BOOL)runOnEnterAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnEnterAction:geoFenceName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnEnterAction:geoFenceName geoPoint:geoPoint];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)runOnStayAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnStayAction:geoFenceName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnStayAction:geoFenceName geoPoint:geoPoint];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)runOnExitAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnExitAction:geoFenceName];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self runOnExitAction:geoFenceName geoPoint:geoPoint];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}


-(NSNumber *)getGeopointCount:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getGeopointCount:query];
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

-(NSNumber *)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getGeopointCount:geoFenceName query:query];
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


#endif

// sync methods with fault return (as exception)

-(GeoCategory *)addCategory:(NSString *)categoryName {
    
    id fault = [self isFaultAddCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args];
}

-(id)deleteCategory:(NSString *)categoryName {
    
    id fault = [self isFaultRemoveCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args];
}

-(id)savePoint:(GeoPoint *)geoPoint {
    
    id fault = [self isFaultGeoPoint:geoPoint responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:geoPoint, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args];
}

-(NSArray<NSString *> *)getCategories {
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:@[]];
}

-(NSArray *)getPoints:(BackendlessGeoQuery *)query {
    
    NSArray *args = [NSArray arrayWithObjects:query, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }

    if (![result isKindOfClass:[NSArray class]]) {
        
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    
    NSArray *collection = result;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];
    
    return collection;
}

-(NSArray *)getClusterPoints:(GeoCluster *)geoCluster {
    
    NSArray *args = @[geoCluster.objectId, geoCluster.geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    if (![result isKindOfClass:[NSArray class]]) {
        
        NSLog(@"GeoService->getCluster: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    NSArray *collection = result;
    [collection type:[GeoPoint class]];
    
    return collection;
}

-(NSArray *)getFencePoints:(NSString *)geoFenceName {
    return [self getFencePoints:geoFenceName query:nil];
}

-(NSArray *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoFenceName, geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    if (![result isKindOfClass:[NSArray class]]) {
        
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    
    NSArray *collection = result;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];
    
    return collection;
}

-(NSArray *)relativeFind:(BackendlessGeoQuery *)query {
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    NSArray *collection = result;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];
    
    return collection;
}

-(id)removePoint:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        return fault;
    
    NSArray *args = @[geoPoint.objectId];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args];
}

-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        return fault;

    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[geoPoint.objectId, query];
    [geoPoint metadata:[invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args]];
    return geoPoint;
}

-(id)runOnEnterAction:(NSString *)geoFenceName {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args];
}

-(id)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName, geoPoint];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args];
}

-(id)runOnStayAction:(NSString *)geoFenceName {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args];
}

-(id)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName, geoPoint];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args];
}

-(id)runOnExitAction:(NSString *)geoFenceName {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args];
}

-(id)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]) || (fault = [self isFaultGeoPoint:geoPoint responder:nil]))
        return fault;
    
    NSArray *args = @[geoFenceName, geoPoint];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args];
}

-(NSNumber *)getGeopointCount:(BackendlessGeoQuery *)query {
    
    if (!query)
        return [backendless throwFault:FAULT_GEO_QUERY_IS_NULL];
    
    NSArray *args = @[query];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args];

}

-(NSNumber *)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query {
    
    if (!geoFenceName || !geoFenceName.length)
        return [backendless throwFault:FAULT_GEO_FENCE_NAME_IS_NULL];
    if (!query)
        return [backendless throwFault:FAULT_GEO_QUERY_IS_NULL];
    
    NSArray *args = @[geoFenceName, query];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args];
    
}

// async methods with responder

-(void)addCategory:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    if ([self isFaultAddCategoryName:categoryName responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args responder:responder];
}

-(void)deleteCategory:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    if ([self isFaultRemoveCategoryName:categoryName responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args responder:responder];
}

-(void)savePoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:geoPoint, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args responder:responder];
}

-(void)getCategories:(id <IResponder>)responder {
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:@[] responder:responder];
}

-(void)getPoints:(BackendlessGeoQuery *)query responder:(id <IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:query, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)getClusterPoints:(GeoCluster *)geoCluster responder:(id <IResponder>)responder {
    
    NSArray *args = @[geoCluster.objectId, geoCluster.geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoCluster.geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args responder:_responder];
}

-(void)getFencePoints:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    [self getFencePoints:geoFenceName query:nil responder:responder];
}

-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoFenceName, geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder {
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args responder:_responder];
}

-(void)removePoint:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;

    NSArray *args = [NSArray arrayWithObjects:geoPoint.objectId, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args responder:responder];
}

-(void)loadMetadata:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;
    
    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[geoPoint.objectId, query];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getMetadata:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoPoint;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args responder:_responder];
}

-(void)runOnEnterAction:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args responder:responder];
}

-(void)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_ENTER_ACTION args:args responder:responder];
}

-(void)runOnStayAction:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args responder:responder];
}

-(void)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_STAY_ACTION args:args responder:responder];
}

-(void)runOnExitAction:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder])
        return;
    
    NSArray *args = @[geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args responder:responder];
}

-(void)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoFenceName:geoFenceName responder:responder] || [self isFaultGeoPoint:geoPoint responder:responder])
        return;
    
    NSArray *args = @[geoFenceName, geoPoint];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ON_EXIT_ACTION args:args responder:responder];
}

-(void)getGeopointCount:(BackendlessGeoQuery *)query responder:(id <IResponder>)responder {
    
    if (!query)
        return [responder errorHandler:FAULT_GEO_QUERY_IS_NULL];
    
    NSArray *args = @[query];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

-(void)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query responder:(id <IResponder>)responder {
    
    if (!geoFenceName || !geoFenceName.length)
        return [responder errorHandler:FAULT_GEO_FENCE_NAME_IS_NULL];
    
    if (!query)
        return [responder errorHandler:FAULT_GEO_QUERY_IS_NULL];
    
    NSArray *args = @[geoFenceName, query];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_COUNT args:args responder:responder];
}

// async methods with block-based callbacks

-(void)addCategory:(NSString *)categoryName response:(void(^)(GeoCategory *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addCategory:categoryName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)deleteCategory:(NSString *)categoryName response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self deleteCategory:categoryName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)savePoint:(GeoPoint *)geoPoint response:(void(^)(GeoPoint *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self savePoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getCategories:(void(^)(NSArray<NSString *> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getCategories:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPoints:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getClusterPoints:(GeoCluster *)geoCluster response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getClusterPoints:geoCluster responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFencePoints:(NSString *)geoFenceName response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFencePoints:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFencePoints:geoFenceName query:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self relativeFind:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removePoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self removePoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loadMetadata:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self loadMetadata:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnEnterAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnEnterAction:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnEnterAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnEnterAction:geoFenceName geoPoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnStayAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnStayAction:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnStayAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnStayAction:geoFenceName geoPoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnExitAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnExitAction:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnExitAction:(NSString *)geoFenceName geoPoint:(GeoPoint *)geoPoint response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnExitAction:geoFenceName geoPoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getGeopointCount:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getGeopointCount:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getGeopointCount:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getGeopointCount:geoFenceName query:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// utilites

-(GEO_RECT)geoRectangle:(GEO_POINT)center length:(double)length widht:(double)widht {
    
    GEO_RECT rect;
    
    double value =  center.latitude + widht/2;
    rect.nordWest.latitude = (value > 90.0) ? 180.0 - value : value;
    value =  center.longitude - length/2;
    rect.nordWest.longitude = (value < -180.0) ? 360.0 + value : value;
    
    value =  center.latitude - widht/2;
    rect.southEast.latitude = (value < -90.0) ? -(value + 180.0) : value;
    value =  center.longitude + length/2;
    rect.southEast.longitude = (value > 180.0) ? value - 360.0 : value;
    
    return rect;
}

-(void)startGeofenceMonitoringGeoPoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder {
    [self startGeofenceMonitoringCallback:[ServerCallback callback:geoPoint] responder:responder];
}

-(void)startGeofenceMonitoring:(id <IGeofenceCallback>)callback responder:(id <IResponder>)responder {
    [self startGeofenceMonitoringCallback:[ClientCallback callback:callback] responder:responder];
}

-(void)startGeofenceMonitoringGeoPoint:(NSString *)geofenceName geoPoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder {
    [self startGeofenceMonitoringCallback:[ServerCallback callback:geoPoint] name:geofenceName responder:responder];
}

-(void)startGeofenceMonitoring:(NSString *)geofenceName callback:(id <IGeofenceCallback>)callback responder:(id <IResponder>)responder {
    [self startGeofenceMonitoringCallback:[ClientCallback callback:callback] name:geofenceName responder:responder];
}

-(void)startGeofenceMonitoringGeoPoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self startGeofenceMonitoringGeoPoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startGeofenceMonitoring:(id <IGeofenceCallback>)callback response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self startGeofenceMonitoring:callback responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startGeofenceMonitoringGeoPoint:(NSString *)geofenceName geoPoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self startGeofenceMonitoringGeoPoint:geofenceName geoPoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)startGeofenceMonitoring:(NSString *)geofenceName callback:(id <IGeofenceCallback>)callback response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self startGeofenceMonitoring:geofenceName callback:callback responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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

#pragma mark -
#pragma mark Private Methods

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

#pragma mark -
#pragma mark Callback Methods

-(id)getResponse:(ResponseContext *)response {
    
    NSArray *collection = response.response;
    BackendlessGeoQuery *geoQuery = response.context;
//    collection.query = geoQuery;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];

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
