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

#define OLD_SAVE_METHOD_ON 0

#import "PersistenceService.h"
#import <objc/runtime.h>
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "HashMap.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessCollection.h"
#import "ObjectProperty.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "BackendlessEntity.h"
#import "DataStoreFactory.h"
#import "BackendlessCache.h"
#import "OfflineModeManager.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is not valid"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"Object ID is not exist"]

// SERVICE NAME
static NSString *SERVER_PERSISTENCE_SERVICE_PATH = @"com.backendless.services.persistence.PersistenceService";
// METHOD NAMES
static NSString *METHOD_CREATE = @"create";
static NSString *METHOD_UPDATE = @"update";
static NSString *METHOD_SAVE = @"save";
static NSString *METHOD_REMOVE = @"remove";
static NSString *METHOD_FINDBYID = @"findById";
static NSString *METHOD_DESCRIBE = @"describe";
static NSString *METHOD_FIND = @"find";
static NSString *METHOD_FIRST = @"first";
static NSString *METHOD_LAST = @"last";
static NSString *METHOD_LOAD = @"loadRelations";
NSString *LOAD_ALL_RELATIONS = @"*";

@interface PersistenceService()
-(NSDictionary *)filteringProperty:(id)object;
-(BOOL)prepareClass:(Class) className;
-(BOOL)prepareObject:(id) object;
-(NSString *)typeClassName:(Class)entity;
-(NSString *)objectClassName:(id)object;
-(NSDictionary *)propertyDictionary:(id)object;
-(BackendlessCollection *)getAsCollection:(id)data query:(BackendlessDataQuery *)query;
// callbacks
-(id)setCurrentPageSize:(ResponseContext *)collection;
-(id)loadRelations:(ResponseContext *)response;
-(id)createResponse:(ResponseContext *)response;
-(id)failWithOfflineMode:(Fault *)error;
@end

@interface Users : BackendlessUser
@end

@implementation Users
@end

@implementation BackendlessUser (AMF)

-(id)onAMFSerialize {
    
    Users *u = [Users new];
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[self getProperties]];
    [data removeObjectsForKeys:@[@"user-token", @"userToken"]];
    [u setProperties:data];
    return u;
}
@end

@implementation NSArray (AMF)

-(id)onAMFSerialize {
    
    if ((self.count > 2) && [self[2] isKindOfClass:[NSString class]]) {
        if ([self[2] isEqualToString:NSStringFromClass([BackendlessUser class])]) {
            NSMutableArray *data = [NSMutableArray arrayWithArray:self];
            data[2] = @"Users";
            return data;
        }
    }
    return self;
}

@end

@implementation Users (AMF)

-(id)onAMFDeserialize {
    
    BackendlessUser *user = [BackendlessUser new];
    NSMutableDictionary *pr = [NSMutableDictionary dictionaryWithDictionary:[Types propertyDictionary:self]];
    [pr removeObjectForKey:@"___class"];
    [user setProperties:pr];
    return user;
}
@end

@implementation NSManagedObject (AMF)

-(id)onAMFDeserialize {
    
    if (!__types.managedObjectContext) {
        return self;
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId LIKE %@", [self valueForKey:PERSIST_OBJECT_ID]];
    [request setPredicate:predicate];
    NSArray *data = [__types.managedObjectContext executeFetchRequest:request error:nil];
    for (id entity in data)
    {
        if (![entity isEqual:self]) {
            [__types.managedObjectContext deleteObject:entity];
            
        }
    }
    return self;
}

@end

@implementation PersistenceService

-(id)init {
	if ( (self=[super init]) ) {
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.ObjectProperty" mapped:[ObjectProperty class]];
	
        _permissions = [DataPermission new];
    }
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC PersistenceService"];
    
    [_permissions release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

// sync methods with fault option

-(NSArray *)describe:(NSString *)classCanonicalName error:(Fault **)fault {
    
    id result = [self describe:classCanonicalName];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        if (!fault) {
            return nil;
        }
        return nil;
    }
    return result;
}

-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault {
    
    id result = [self save:entityName entity:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = [self update:entityName entity:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)save:(id)entity error:(Fault **)fault {
    
    id result = [self save:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)create:(id)entity error:(Fault **)fault {
    
    id result = [self create:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)update:(id)entity error:(Fault **)fault {
    
    id result = [self update:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)load:(id)object relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = [self load:object relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self load:object relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
    id result = [self find:entity dataQuery:dataQuery];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)first:(Class)entity error:(Fault **)fault {
    
    id result = [self first:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)last:(Class)entity error:(Fault **)fault {
    
    id result = [self last:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self first:entity relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self last:entity relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(id)entity error:(Fault **)fault {
    
    id result = [self findByObject:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(id)entity relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = [self findByObject:entity relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self findByObject:entity relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props error:(Fault **)fault {
    
    id result = [self findByObject:className keys:props];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = [self findByObject:className keys:props relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self findByObject:className keys:props relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid error:(Fault **)fault {
    
    id result = [self findById:entityName sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = [self findById:entityName sid:sid relations:relations];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = [self findById:entityName sid:sid relations:relations relationsDepth:relationsDepth];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(id)findByClassId:(Class)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = [self findByClassId:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)remove:(id)entity error:(Fault **)fault {
    
    id result = [self remove:entity];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)remove:(Class)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = [self remove:entity sid:sid];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
    [self removeAll:entity dataQuery:dataQuery];
    return YES;
}

// sync methods with fault return  (as exception)

-(NSArray *)describe:(NSString *)classCanonicalName {
    
    if (!classCanonicalName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, classCanonicalName, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args];
}

-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity {
    
    if (!entity || !entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
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

#if OLD_SAVE_METHOD_ON
    id objectId = [self getObjectId:entity];
    [DebLog log:@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PersistenceService -> save: objectId = %@", [objectId isKindOfClass:[NSNumber class]]?@"NO":objectId];
    if (![objectId isKindOfClass:[NSNumber class]])
        return (objectId && [objectId isKindOfClass:[NSString class]]) ? [backendless.persistenceService update:entity] : [backendless.persistenceService create:entity];
#endif
    
    [DebLog log:@"PersistenceService -> save: class = %@, entity = %@", [self objectClassName:entity], [self propertyDictionary:entity]];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], [self propertyDictionary:entity]];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_SAVE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    return result;
}

-(id)create:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [DebLog log:@"PersistenceService -> create: class = %@, entity = %@", [self objectClassName:entity], entity];
    
    [self prepareObject:entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self objectClassName:entity], props, nil];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    
    if ([[entity class] isSubclassOfClass:[NSManagedObject class]]) {
        [__types.managedObjectContext deleteObject:entity];
    }
    
    return result;
}

-(id)update:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];

    [DebLog log:@"PersistenceService -> update: class = %@, entity = %@", [self objectClassName:entity], entity];
    
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self objectClassName:entity], props, nil];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    return result;
}

-(id)load:(id)object relations:(NSArray *)relations {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    NSArray *keys = [result allKeys];
    for(NSString *propertyName in keys) {
        if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
            [(BackendlessUser *) object setProperty:propertyName object:[result valueForKey:propertyName]];
            continue;
        }
        if ([[object valueForKey:propertyName] isKindOfClass:[NSNull class]]) {
            continue;
        }
        [object setValue:[result valueForKey:propertyName] forKey:propertyName];
    }
    return object;
}

-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations, @(relationsDepth)];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    NSArray *keys = [result allKeys];
    for(NSString *propertyName in keys) {
        if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
            [(BackendlessUser *) object setProperty:propertyName object:[result valueForKey:propertyName]];
            continue;
        }
        if ([[object valueForKey:propertyName] isKindOfClass:[NSNull class]]) {
            continue;
        }
        [object setValue:[result valueForKey:propertyName] forKey:propertyName];
    }
    return object;
}

-(BackendlessCollection *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], dataQuery, nil];
    id result = [backendlessCache invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args];
#if 1
    return [result isKindOfClass:[Fault class]]? result : [self getAsCollection:result query:dataQuery];
#else
    if (![result isKindOfClass:[Fault class]])
    {
        BackendlessCollection *bc = result;
        [bc pageSize:dataQuery.queryOptions.pageSize.integerValue];
        bc.backendlessQuery = dataQuery;
        return bc;
    }
    else
        return result;
#endif
}

-(id)first:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args];
}

-(id)last:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args];
}

-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args];
}

-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args];
}

-(id)findByObject:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(id)entity relations:(NSArray *)relations {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity, relations];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity, relations, @(relationsDepth)];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, className, props];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, className, props, relations];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, className, props, relations, @(relationsDepth)];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
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

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByClassId:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
    return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
    return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(NSNumber *)remove:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
}

-(NSNumber *)remove:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
}

-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    BackendlessCollection *bc = [backendless.persistenceService find:entity dataQuery:dataQuery];
    [bc removeAll];
    
    [DebLog log:@"PersistenceService -> removeAll: totalObjects = %@", bc.totalObjects];
}

// async methods with responder

-(void)describe:(NSString *)classCanonicalName responder:(id <IResponder>)responder {
    
    if (!classCanonicalName)
    return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, classCanonicalName, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args responder:responder];
}

-(void)save:(NSString *)entityName entity:(NSDictionary *)entity responder:(id <IResponder>)responder {
    
    if (!entity || !entityName) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, entity, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        
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
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        
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

#if OLD_SAVE_METHOD_ON
    id objectId = [self getObjectId:entity];
    if (![objectId isKindOfClass:[NSNumber class]])
        return (objectId && [objectId isKindOfClass:[NSString class]]) ?
            [backendless.persistenceService update:entity responder:responder] : [backendless.persistenceService create:entity responder:responder];
#endif
    
    [DebLog log:@"PersistenceService -> save: class = %@, entity = %@", [self objectClassName:entity], [self propertyDictionary:entity]];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], [self propertyDictionary:entity]];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(createResponse:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = entity;
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = _responder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_SAVE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_SAVE args:args responder:_responder];
}

-(void)create:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareObject:entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self objectClassName:entity], props, nil];
    Responder *createResponder = [Responder responder:self selResponseHandler:@selector(createResponse:) selErrorHandler:nil];
    createResponder.chained = responder;
    createResponder.context = entity;
    if ([OfflineModeManager sharedInstance].isOfflineMode)
    {
        Responder *offlineModeResponder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = createResponder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:createResponder];
}

-(void)update:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self objectClassName:entity], props, nil];
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

-(void)load:(id)object relations:(NSArray *)relations responder:(id<IResponder>)responder {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(loadRelations:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = @{@"object":object, @"relations":relations};
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args responder:_responder];
}

-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id<IResponder>)responder {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations, @(relationsDepth)];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(loadRelations:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = @{@"object":object, @"relations":relations};
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args responder:_responder];
}

-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], dataQuery, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(setCurrentPageSize:) selErrorHandler:nil];
    _responder.context = dataQuery;
    _responder.chained = responder;
    [backendlessCache invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responder:_responder];
}

-(void)first:(Class)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:responder];
}

-(void)last:(Class)entity responder:(id <IResponder>)responder {
    
    if (!entity) 
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:responder];
}

-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!entity)
    return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:responder];
}

-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!entity)
    return [responder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:responder];
}

-(void)findByObject:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity, relations, @(relationsDepth)];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByObject:(id)entity relations:(NSArray *)relations responder:(id<IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity],entity, relations];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props responder:(id <IResponder>)responder {
    
    if (!className)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!props)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, className, props, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!className)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!props)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, className, props, relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations responder:(id<IResponder>)responder {
    
    if (!className)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!props)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, className, props, relations, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
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

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth responder:(id <IResponder>)responder {
    
    if (!entityName)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations responder:(id<IResponder>)responder {
    
    if (!entityName)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, entityName, sid, relations, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)findByClassId:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entity)
    return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
    return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:responder];
}

-(void)remove:(id)entity responder:(id <IResponder>)responder {
    
    if (!entity)
    return [responder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, [self objectClassName:entity], entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:responder];
}

-(void)remove:(Class)entity sid:(NSString *)sid responder:(id <IResponder>)responder {
    
    if (!entity)
        return [responder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [responder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [self typeClassName:entity], sid, nil];
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

// async methods with block-base callbacks

-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self describe:classCanonicalName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

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

-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self load:object relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    [self load:object relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
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

-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self first:entity relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self last:entity relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByObject:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByObject:(id)entity relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:entity relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:entity relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)findByObject:(NSString *)className keys:(NSDictionary *)props response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:className keys:props responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:className keys:props relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByObject:className keys:props relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:entityName sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:entityName sid:sid relations:relations responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:entityName sid:sid relations:relations relationsDepth:relationsDepth responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findByClassId:(Class)entity sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findByClassId:entity sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:entity responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)remove:(Class)entity sid:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self remove:entity sid:sid responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)removeAll:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    [backendless.persistenceService find:entity dataQuery:dataQuery
        response:^(BackendlessCollection *bc) {
            [DebLog log:@"PersistenceService -> removeAll: totalObjects = %@", bc.totalObjects];
            [bc removeAll:responseBlock error:errorBlock];
        }
        error:^(Fault *fault) {
            [DebLog log:@"PersistenceService -> removeAll: FAULT: %@", fault];
            errorBlock(fault);
        }];
}

// IDataStore class factory

-(id <IDataStore>)of:(Class)entityClass {
    return [DataStoreFactory createDataStore:entityClass];
}

// utilites
-(id)getObjectId:(id)object {
    id objectId = nil;
    return [object getPropertyIfResolved:PERSIST_OBJECT_ID value:&objectId] ? objectId : [NSNumber numberWithBool:NO];
}

-(NSDictionary *)getObjectMetadata:(id)object {
    
    const NSString *metadataKeys = @",___class,__meta,created,objectId,updated,";
    
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    NSDictionary *props = [self propertyDictionary:object];
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

#if 0
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
#endif

#pragma mark -
#pragma mark Private Methods

-(NSDictionary *)filteringProperty:(id)object
{
    NSDictionary *properties = [self propertyDictionary:object];
    NSMutableDictionary *result= [NSMutableDictionary dictionaryWithDictionary:properties];
    if ([result valueForKey:@"__meta"] == nil) {
        [result removeObjectForKey:@"__meta"];
    }
    return result;
}

#if 0
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
#endif

#if !OLD_SAVE_METHOD_ON
-(BOOL)prepareClass:(Class)className {
    return YES;
}

-(BOOL)prepareObject:(id)object {
    return YES;
}
#else
-(BOOL)prepareClass:(Class)className {
    id object = [Types classInstance:className];
    BOOL result = [object resolveProperty:PERSIST_OBJECT_ID];
    [object resolveProperty:@"__meta"];
    if ([[object class] isSubclassOfClass:[NSManagedObject class]]) {
        [__types.managedObjectContext deleteObject:object];
    }
    return result;
}

-(BOOL)prepareObject:(id)object {
    [object resolveProperty:PERSIST_OBJECT_ID value:nil];
    [object resolveProperty:@"__meta" value:nil];
    return YES;
}
#endif

-(NSString *)typeClassName:(Class)entity {
    
    NSString *name = [__types typeMappedClassName:entity];
    if ([name isEqualToString:NSStringFromClass([BackendlessUser class])]) {
        name = @"Users";
    }
    return name;
}

-(NSString *)objectClassName:(id)object {
    
    NSString *name = [__types objectMappedClassName:object];
    if ([name isEqualToString:NSStringFromClass([BackendlessUser class])]) {
        name = @"Users";
    }
    return name;
}

-(NSDictionary *)propertyDictionary:(id)object {
    
    if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[(BackendlessUser *) object getProperties]];
        [data removeObjectsForKeys:@[@"user-token", @"userToken"]];
        
        return data;
    }
#if 0
    return [Types propertyDictionary:object];
#else
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[Types propertyDictionary:object]];
    [data removeObjectsForKeys:@[@"__meta", @"___class"]];
    
    return data;
    
#endif
}

-(BackendlessCollection *)getAsCollection:(id)data query:(BackendlessDataQuery *)query {
    
    BackendlessCollection *collection = nil;
    
    if ([data isKindOfClass:[BackendlessCollection class]]) {
        collection = data;
    }
    else
        if ([data isKindOfClass:[NSDictionary class]]) {
            collection = [[BackendlessCollection new] autorelease];
            [collection resolveProperties:data];
        }
    
    if (collection) {
        collection.backendlessQuery = query;
        [collection pageSize:query.queryOptions.pageSize.integerValue];
    }
    
    [DebLog logN:@"PersistenceService -> getAsCollection: %@ -> \n%@", data, collection];
    
    return collection;
}

#pragma mark -
#pragma mark Callback Methods

-(id)setCurrentPageSize:(ResponseContext *)response {
    return [self getAsCollection:response.response query:response.context];
}

-(id)loadRelations:(ResponseContext *)response {
    
    NSArray *relations = [response.context valueForKey:@"relations"];
    BackendlessEntity *object = [response.context valueForKey:@"object"];
    id result = response.response;
    for(NSString *propertyName in relations)
    {
        if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
            [(BackendlessUser *) object setProperty:propertyName object:[result valueForKey:propertyName]];
            continue;
        }
        if ([[result valueForKey:propertyName] isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        [object setValue:[result valueForKey:propertyName] forKey:propertyName];
        
    }
    return object;
}

-(id)createResponse:(ResponseContext *)response {
    
    id object = response.context;
    if ([[object class] isSubclassOfClass:[NSManagedObject class]]) {
        [__types.managedObjectContext deleteObject:object];
    }
    response.context = nil;
    return response.response;
}

-(id)failWithOfflineMode:(Fault *)error {
    
    Responder *responder = error.context;
    id res = [[OfflineModeManager sharedInstance] saveObject:responder.context];
    [responder.chained responseHandler:res];
    responder.chained = nil;
    return nil;
}

@end
