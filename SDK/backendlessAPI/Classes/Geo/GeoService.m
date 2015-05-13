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
#import "BackendlessCollection.h"
#import "LocationTracker.h"
#import "GeoFence.h"
#import "GeoFenceMonitoring.h"

#define FAULT_CATEGORY_NAME_IS_NULL [Fault fault:@"Category name is NULL" faultCode:@"4005"]
#define FAULT_CATEGORY_NAME_IS_EMPTY [Fault fault:@"Category name is empty" faultCode:@"4006"]
#define FAULT_CATEGORY_NAME_IS_DEFAULT [Fault fault:@"Category name is 'Default'" faultCode:@"4007"]
#define FAULT_GEO_POINT_IS_NULL [Fault fault:@"Geo point is NULL" faultCode:@"4000"]
#define FAULT_GEO_POINT_ID_IS_NULL [Fault fault:@"Geo point ID is NULL" faultCode:@"4000"]
#define FAULT_GEO_FENCE_NAME_IS_NULL [Fault fault:@"Geo fence name is NULL" faultCode:@"4000"]

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
static NSString *METHOD_RUN_ONSTAY_ACTION = @"runOnStayAction";
static NSString *METHOD_GET_FENCE = @"getFence";

@interface GeoService ()
-(Fault *)isFaultCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder;
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
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geofence.model.GeoFenceAMF" mapped:[GeoFence class]];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC GeoService"];
    	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

+(NSString *)servicePath {
    return SERVER_GEO_SERVICE_PATH;
}


// sync methods with fault option

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

-(NSArray *)getCategoriesError:(Fault **)fault {
    
    id result = [self getCategories];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessCollection *)getPoints:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self getPoints:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessCollection *)getClusterPoints:(GeoCluster *)geoCluster error:(Fault **)fault {
    
    id result = [self getClusterPoints:geoCluster];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self relativeFind:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessCollection *)getFencePoints:(NSString *)geoFenceName error:(Fault **)fault {
    return [self getFencePoints:geoFenceName query:nil error:fault];
}

-(BackendlessCollection *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query error:(Fault **)fault {
    
    id result = [self getFencePoints:geoFenceName query:query];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSNumber *)runOnStayAction:(NSString *)geoFenceName error:(Fault **)fault {
    
    id result = [self runOnStayAction:geoFenceName];
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

// sync methods with fault return (as exception)

-(GeoCategory *)addCategory:(NSString *)categoryName {
    
    id fault = [self isFaultCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args];
}

-(id)deleteCategory:(NSString *)categoryName {
    
    id fault = [self isFaultCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args];
}

-(id)savePoint:(GeoPoint *)geoPoint {
    
    id fault = [self isFaultGeoPoint:geoPoint responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, geoPoint, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args];
}

-(NSArray *)getCategories {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:args];
}

-(BackendlessCollection *)getPoints:(BackendlessGeoQuery *)query {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, query, nil];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }

    if (![result isKindOfClass:[BackendlessCollection class]]) {
        
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    
    BackendlessCollection *collection = result;
    collection.query = query;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];
    
    return collection;
}

-(BackendlessCollection *)getClusterPoints:(GeoCluster *)geoCluster {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geoCluster.objectId, geoCluster.geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    if (![result isKindOfClass:[BackendlessCollection class]]) {
        
        NSLog(@"GeoService->getCluster: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    
    BackendlessCollection *collection = result;
    collection.query = geoCluster.geoQuery;
    [collection type:[GeoPoint class]];
    
    return collection;
}

-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, query];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    BackendlessCollection *collection = result;
    collection.query = query;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];

    return collection;
}

-(BackendlessCollection *)getFencePoints:(NSString *)geoFenceName {
    return [self getFencePoints:geoFenceName query:nil];
}

-(BackendlessCollection *)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[backendless.appID, backendless.versionNum, geoFenceName, geoQuery];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    if (![result isKindOfClass:[BackendlessCollection class]]) {
        
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
    
    BackendlessCollection *collection = result;
    collection.query = geoQuery;
    [collection type:[GeoPoint class]];
    
    [self setReferenceToCluster:collection];
    
    return collection;
}

-(NSNumber *)runOnStayAction:(NSString *)geoFenceName {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:nil]))
        return fault;
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geoFenceName];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ONSTAY_ACTION args:args];
}

-(id)removePoint:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        return fault;
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geoPoint.objectId];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args];
}

-(GeoPoint *)loadMetadata:(GeoPoint *)geoPoint {
    
    id fault = nil;
    if ((fault = [self isFaultGeoPoint:geoPoint responder:nil]) || (fault = [self isFaultGeoPointId:geoPoint.objectId responder:nil]))
        return fault;

    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[backendless.appID, backendless.versionNum, geoPoint.objectId, query];
    [geoPoint metadata:[invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args]];
    return geoPoint;
}

// async methods with responder

-(void)addCategory:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    if ([self isFaultCategoryName:categoryName responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_ADD_CATEGORY args:args responder:responder];
}

-(void)deleteCategory:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    if ([self isFaultCategoryName:categoryName responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args responder:responder];
}

-(void)savePoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder])
        return;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, geoPoint, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:geoPoint.objectId?METHOD_UPDATE_POINT:METHOD_ADD_POINT args:args responder:responder];
}

-(void)getCategories:(id <IResponder>)responder {

    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORIES args:args responder:responder];
}

-(void)getPoints:(BackendlessGeoQuery *)query responder:(id <IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, query, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)getClusterPoints:(GeoCluster *)geoCluster responder:(id <IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geoCluster.objectId, geoCluster.geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoCluster.geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_GEOPOINTS args:args responder:_responder];
}

-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, query];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args responder:_responder];
}

-(void)getFencePoints:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    [self getFencePoints:geoFenceName query:nil responder:responder];
}

-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:responder]))
        return;
    
    BackendlessGeoQuery *geoQuery = query?query:[BackendlessGeoQuery query];
    NSArray *args = @[backendless.appID, backendless.versionNum, geoFenceName, geoQuery];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoQuery;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS args:args responder:_responder];
}

-(void)runOnStayAction:(NSString *)geoFenceName responder:(id<IResponder>)responder {
    
    id fault = nil;
    if ((fault = [self isFaultGeoFenceName:geoFenceName responder:responder]))
        return;
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geoFenceName];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_RUN_ONSTAY_ACTION args:args responder:responder];
}

-(void)removePoint:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;

    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, geoPoint.objectId, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args responder:responder];
}

-(void)loadMetadata:(GeoPoint *)geoPoint responder:(id<IResponder>)responder {
    
    if ([self isFaultGeoPoint:geoPoint responder:responder] || [self isFaultGeoPointId:geoPoint.objectId responder:responder])
        return;
    
    id query = [geoPoint isKindOfClass:[GeoCluster class]]? [(GeoCluster *)geoPoint geoQuery] : [NSNull null];
    NSArray *args = @[backendless.appID, backendless.versionNum, geoPoint.objectId, query];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getMetadata:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = geoPoint;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_LOAD_METADATA args:args responder:_responder];
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

-(void)getCategories:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getCategories:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getPoints:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getClusterPoints:(GeoCluster *)geoCluster response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getClusterPoints:geoCluster responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self relativeFind:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFencePoints:(NSString *)geoFenceName response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFencePoints:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getFencePoints:(NSString *)geoFenceName query:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getFencePoints:geoFenceName query:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)runOnStayAction:(NSString *)geoFenceName response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self runOnStayAction:geoFenceName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removePoint:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self removePoint:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loadMetadata:(GeoPoint *)geoPoint response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self loadMetadata:geoPoint responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// geo fence minitoring
/*
 
 public void startGeofenceMonitoring( GeoPoint geoPoint,
 final AsyncCallback<Void> responder ) throws BackendlessException
 {
 ICallback bCallback = new ServerCallback( geoPoint );
 
 startGeofenceMonitoring( bCallback, responder );
 }
 
 public void startGeofenceMonitoring( IGeofenceCallback callback,
 final AsyncCallback<Void> responder ) throws BackendlessException
 {
 ICallback bCallback = new ClientCallback( callback );
 
 startGeofenceMonitoring( bCallback, responder );
 }
 
 public void startGeofenceMonitoring( String geofenceName, GeoPoint geoPoint,
 final AsyncCallback<Void> responder ) throws BackendlessException
 {
 ICallback bCallback = new ServerCallback( geoPoint );
 
 startGeofenceMonitoring( bCallback, geofenceName, responder );
 }
 
 public void startGeofenceMonitoring( String geofenceName, IGeofenceCallback callback,
 final AsyncCallback<Void> responder ) throws BackendlessException
 {
 ICallback bCallback = new ClientCallback( callback );
 
 startGeofenceMonitoring( bCallback, geofenceName, responder );
 }
 
 public void stopGeofenceMonitoring()
 {
 GeoFenceMonitoring.getInstance().removeGeoFences();
 LocationTracker.getInstance().removeListener( GeoFenceMonitoring.NAME );
 }
 
 public void stopGeofenceMonitoring( String geofenceName )
 {
 GeoFenceMonitoring.getInstance().removeGeoFence( geofenceName );
 if( !GeoFenceMonitoring.getInstance().isMonitoring() )
 {
 LocationTracker.getInstance().removeListener( GeoFenceMonitoring.NAME );
 }
 }
 */


/*
 
 private void startGeofenceMonitoring( final ICallback callback, final AsyncCallback<Void> responder )
 {
 Invoker.invokeAsync( GEO_MANAGER_SERVER_ALIAS, "getFences", new Object[] { Backendless.getApplicationId(), Backendless.getVersion() }, new AsyncCallback<GeoFence[]>()
 {
 @Override
 public void handleResponse( GeoFence[] geoFences )
 {
 try
 {
 addFenceMonitoring( callback, geoFences );
 
 if( responder != null )
 responder.handleResponse( null );
 }
 catch( Exception ex )
 {
 if( responder != null )
 responder.handleFault( new BackendlessFault( ex ) );
 }
 }
 
 @Override
 public void handleFault( BackendlessFault fault )
 {
 responder.handleFault( fault );
 }
 } );
 }
 */

/*
 
 private void startGeofenceMonitoring( final ICallback callback, String geofenceName,
 final AsyncCallback<Void> responder )
 {
 Invoker.invokeAsync( GEO_MANAGER_SERVER_ALIAS, "getFence", new Object[] { Backendless.getApplicationId(), Backendless.getVersion(), geofenceName }, new AsyncCallback<GeoFence>()
 {
 @Override
 public void handleResponse( GeoFence geoFences )
 {
 try
 {
 addFenceMonitoring( callback, geoFences );
 
 if( responder != null )
 responder.handleResponse( null );
 }
 catch( Exception ex )
 {
 if( responder != null )
 responder.handleFault( new BackendlessFault( ex ) );
 }
 }
 
 @Override
 public void handleFault( BackendlessFault fault )
 {
 responder.handleFault( fault );
 }
 } );
 }
 */

-(void)startGeofenceMonitoring:(id <ICallback>)callback name:(NSString *)geofenceName responder:(Responder *)responder {
    
    NSArray *args = @[backendless.appID, backendless.versionNum, geofenceName];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getGeoFence:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = callback;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_FENCE args:args responder:_responder];

}

 /*
 
 private void addFenceMonitoring( ICallback callback, GeoFence... geoFences )
 {
 
 if( geoFences.length == 0 )
 {
 return;
 }
 
 if( geoFences.length == 1 )
 {
 GeoFenceMonitoring.getInstance().addGeoFence( geoFences[ 0 ], callback );
 }
 else
 {
 GeoFenceMonitoring.getInstance().addGeoFences( new HashSet<GeoFence>( Arrays.asList( geoFences ) ), callback );
 }
 
 if( !LocationTracker.getInstance().isContainListener( GeoFenceMonitoring.NAME ) )
 {
 try
 {
 LocationTracker.getInstance().addListeners( GeoFenceMonitoring.NAME, GeoFenceMonitoring.getInstance() );
 }
 catch( RuntimeException e )
 {
 GeoFenceMonitoring.getInstance().removeGeoFences();
 throw e;
 }
 }
 }
 */

-(void)addFenceMonitoring:(id <ICallback>)callback geoFences:(NSArray *)geoFences {
    
    if (!callback || !geoFences || !geoFences.count) {
        return;
    }
    
    GeoFenceMonitoring *monitiring = [GeoFenceMonitoring sharedInstance];
    geoFences.count == 1? [monitiring addGeoFence:geoFences[0] callback:callback] : [monitiring addGeoFences:geoFences callback:callback];
    
    LocationTracker *locationTracker = [LocationTracker sharedInstance];
    NSString *listenerName = [monitiring listenerName];
    if (![locationTracker isContainListener:listenerName]) {
        [locationTracker addListener:listenerName listener:monitiring];
    }
}

-(id)getGeoFence:(ResponseContext *)response {
    
    NSDictionary *metadata = response.response;
    GeoPoint *geoPoint = response.context;
    [geoPoint metadata:metadata];
    return geoPoint;
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

-(void)setReferenceToCluster:(BackendlessCollection *)points {
    
    BackendlessGeoQuery *geoQuery = points.query;
    for (id geoPoint in points.data) {
        if ([geoPoint isKindOfClass:[GeoCluster class]]) {
            GeoCluster *geoCluster = geoPoint;
            geoCluster.geoQuery = geoQuery;
        }
    }
}


#pragma mark -
#pragma mark Private Methods

-(Fault *)isFaultCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    Fault *fault = (!categoryName) ? FAULT_CATEGORY_NAME_IS_NULL : (!categoryName.length) ? FAULT_CATEGORY_NAME_IS_EMPTY :
                    ([categoryName isEqualToString:DEFAULT_CATEGORY_NAME]) ? FAULT_CATEGORY_NAME_IS_DEFAULT : nil;
    
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

#pragma mark -
#pragma mark Callback Methods

-(id)getResponse:(ResponseContext *)response {
    
    BackendlessCollection *collection = response.response;
    BackendlessGeoQuery *geoQuery = response.context;
    collection.query = geoQuery;
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

-(id)getError:(id)error {
    return error;
}

@end
