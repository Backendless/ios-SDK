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

#define FAULT_CATEGORY_NAME_IS_NULL [Fault fault:@"Category name is NULL" faultCode:@"4005"]
#define FAULT_CATEGORY_NAME_IS_EMPTY [Fault fault:@"Category name is empty" faultCode:@"4006"]
#define FAULT_CATEGORY_NAME_IS_DEFAULT [Fault fault:@"Category name is 'Default'" faultCode:@"4007"]
#define FAULT_GEO_POINT_IS_NULL [Fault fault:@"Geo point is NULL" faultCode:@"4000"]

// SERVICE NAME
static NSString *SERVER_GEO_SERVICE_PATH = @"com.backendless.services.geo.GeoService";
// METHOD NAMES
static NSString *METHOD_GET_CATEGORY = @"addCategory";
static NSString *METHOD_DELETE_CATEGORY = @"deleteCategory";
static NSString *METHOD_DELETE_GEOPOINT = @"removePoint";
static NSString *METHOD_ADD_POINT = @"addPoint";
static NSString *METHOD_UPDATE_POINT = @"updatePoint";
//static NSString *METHOD_SAVE_POINT = @"savePoint";
static NSString *METHOD_GET_CATEGORIES = @"getCategories";
static NSString *METHOD_GET_POINTS = @"getPoints";
static NSString *METHOD_GET_POINTS_WITH_MATCHES = @"relativeFind";

@interface GeoService ()
-(Fault *)isFaultCategoryName:(NSString *)categoryName responder:(id <IResponder>)responder;
-(Fault *)isFaultGeoPoint:(GeoPoint *)geoPoint responder:(id <IResponder>)responder;
-(id)getResponse:(ResponseContext *)response;
-(id)getError:(id)error;
-(id)removeGeoPoint:(NSString*)pointId;
@end


@implementation GeoService

-(id)init {
	if ( (self=[super init]) ) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoCategory" mapped:[GeoCategory class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.BackendlesGeoQuery" mapped:[BackendlessGeoQuery class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.SearchMatchesResult" mapped:[SearchMatchesResult class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC GeoService"];
    	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// sync methods

//new
-(BOOL)deleteGeoPoint:(NSString *)geopointId error:(Fault **)fault
{
    id result = [self removeGeoPoint:geopointId];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(GeoCategory *)addCategory:(NSString *)categoryName error:(Fault **)fault
{
    id result = [self addCategory:categoryName];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)deleteCategory:(NSString *)categoryName error:(Fault **)fault
{
    id result = [self deleteCategory:categoryName];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(GeoPoint *)savePoint:(GeoPoint *)geoPoint error:(Fault **)fault
{
    id result = [self savePoint:geoPoint];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)getCategoriesError:(Fault **)fault
{
    id result = [self getCategories];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BackendlessCollection *)getPoints:(BackendlessGeoQuery *)query error:(Fault **)fault
{
    id result = [self getPoints:query];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query error:(Fault **)fault
{
    id result = [self relativeFind:query];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(GeoCategory *)addCategory:(NSString *)categoryName {
    
    id fault = [self isFaultCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORY args:args];
}

-(id)deleteCategory:(NSString *)categoryName {
    
    id fault = [self isFaultCategoryName:categoryName responder:nil];
    if (fault)
        return fault;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_CATEGORY args:args];
}
-(id)removeGeoPoint:(NSString*)pointId
{
    if (pointId.length == 0) {
        return [Fault fault:@"Empty point id"];
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, pointId, nil];
    return [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args];
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

#if 1
    if (![result isKindOfClass:[BackendlessCollection class]]) {
        
        NSLog(@"GeoService->getPoints: (ERROR) [%@]\n%@", [result class], result);
        return nil;
    }
#endif
    
    BackendlessCollection *collection = result;
    collection.backendlessQuery = query;
    return collection;
}

-(BackendlessCollection *)relativeFind:(BackendlessGeoQuery *)query
{
    NSArray *args = @[backendless.appID, backendless.versionNum, query];
    id result = [invoker invokeSync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    BackendlessCollection *collection = result;
    collection.backendlessQuery = query;
    return collection;
}

// async methods with responder

-(void)addCategory:(NSString *)categoryName responder:(id <IResponder>)responder {
    
    if ([self isFaultCategoryName:categoryName responder:responder])
        return;
	
    [DebLog log:@"GeoService -> addCategory:"];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, categoryName, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_CATEGORY args:args responder:responder];
}
-(void)deleteGeoPoint:(NSString *)pointId responder:(id<IResponder>)responder
{
    if (pointId.length == 0) {
        return;
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, pointId, nil];
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_DELETE_GEOPOINT args:args responder:responder];
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

-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id<IResponder>)responder
{
    NSArray *args = @[backendless.appID, backendless.versionNum, query];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
    _responder.chained = responder;
    _responder.context = query;
    [invoker invokeAsync:SERVER_GEO_SERVICE_PATH method:METHOD_GET_POINTS_WITH_MATCHES args:args responder:_responder];
}

// async methods with block-base callbacks

-(void)addCategory:(NSString *)categoryName response:(void(^)(GeoCategory *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self addCategory:categoryName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)deleteGeoPoint:(NSString *)pointId response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self deleteGeoPoint:pointId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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

-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self relativeFind:query responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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

-(id)getResponse:(ResponseContext *)response
{
//    NSLog(@"%@", response);
//    NSLog(@"%@", response.response);
//    NSLog(@"%@", response.context);
    BackendlessCollection *collection = response.response;
    BackendlessGeoQuery *geoQuery = response.context;
    collection.backendlessQuery = geoQuery;
    [collection pageSize:geoQuery.pageSize.integerValue];
    return collection;
}

-(id)getError:(id)error
{
    return error;
}

@end
