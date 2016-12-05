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
#define _SAVE_OBJECT_AS_DICTIONARY_ 0
#define _DIRECTLY_SAVE_METHOD 0

#define _PERSISTENCE_UDPATE_CURRENTUSER_ON_ 1


#import "PersistenceService.h"
#import <objc/runtime.h>
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "HashMap.h"
#import "ClassCastException.h"
#import "Backendless.h"
#import "Invoker.h"
#import "ObjectProperty.h"
#import "QueryOptions.h"
#import "BackendlessDataQuery.h"
#import "BackendlessEntity.h"
#import "DataStoreFactory.h"
#import "BackendlessCache.h"
#import "OfflineModeManager.h"
#import "ObjectProperty.h"

#define FAULT_NO_ENTITY [Fault fault:@"Entity is missing or null" detail:@"Entity is missing or null" faultCode:@"1900"]
#define FAULT_OBJECT_ID_IS_NOT_EXIST [Fault fault:@"objectId is missing or null" detail:@"objectId is missing or null" faultCode:@"1901"]
#define FAULT_NAME_IS_NULL [Fault fault:@"Name is missing or null" detail:@"Name is missing or null" faultCode:@"1902"]

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
static NSString *METHOD_CALL_STORED_VIEW = @"callStoredView";
static NSString *METHOD_CALL_STORED_PROCEDURE = @"callStoredProcedure";
static NSString *METHOD_COUNT = @"count";
static NSString *DELETE_RELATION = @"deleteRelation";
static NSString *CREATE_RELATION = @"setRelation";
//
NSString *LOAD_ALL_RELATIONS = @"*";

@interface PersistenceService()
-(NSDictionary *)filteringProperty:(id)object;
-(BOOL)prepareClass:(Class) className;
-(BOOL)prepareObject:(id) object;
-(NSString *)typeClassName:(Class)entity;
-(NSString *)objectClassName:(id)object;
-(NSDictionary *)propertyDictionary:(id)object;
-(id)propertyObject:(id)object;
-(NSArray *)getAsCollection:(id)data query:(BackendlessDataQuery *)query;
-(id)setRelations:(NSArray *)relations object:(id)object response:(id)response;
// callbacks
-(id)setCurrentPageSize:(ResponseContext *)collection;
-(id)loadRelations:(ResponseContext *)response;
-(id)createResponse:(ResponseContext *)response;
-(id)failWithOfflineMode:(Fault *)error;
@end

#if _IS_USERS_CLASS_
@interface Users : BackendlessUser
@end

@implementation Users
@end

@implementation Users (AMF)

// overrided method MUST return 'self' to avoid a deserialization breaking
-(id)onAMFDeserialize {
    
#if 1 // http://bugs.backendless.com/browse/BKNDLSS-11933
    
#if 1 // avoid to update self to self (self relation) - app crash appears in this case
    NSDictionary *data = [Types propertyDictionary:self];
    NSArray *props = [data allKeys];
    for (NSString *prop in props) {
        id value = data[prop];
        if (value != self) {
            [self setProperty:prop object:value];
        }
    }
    return self;
#else
    [self assignProperties:[Types propertyDictionary:self]];
    return self;
#endif
    
#else
    BackendlessUser *user = [BackendlessUser new];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[Types propertyDictionary:self]];
    
    [DebLog log:@"Users -> onAMFDeserialize: BackendlessUser.properties = %@", properties];
    
    [user assignProperties:properties];
    return user;
#endif
}
@end
#endif

#if TYPES_AMF_DESERIALIZE_POSTPROCESSOR_ON
@implementation Types (AMF)

+(id)pastAMFDeserialize:(id)obj {
    
    if (![obj isKindOfClass:[BackendlessUser class]])
        return obj;
    
    BackendlessUser *user = (BackendlessUser *)obj;
    
#if 0 // avoid to update self to self (self relation) - app crash appears in this case ( http://bugs.backendless.com/browse/BKNDLSS-11933 )
    NSDictionary *data = [Types propertyDictionary:user];
    NSArray *props = [data allKeys];
    for (NSString *prop in props) {
        id value = data[prop];
        if (value != user) {
            [user setProperty:prop object:value];
        }
    }
    return user;
#else
    NSDictionary *props = [Types propertyDictionary:user];
    //[user replaceAllProperties]; // http://bugs.backendless.com/browse/BKNDLSS-12973
    [user assignProperties:props];
    return user;
#endif
}
@end
#endif

@implementation BackendlessUser (AMF)

-(id)onAMFSerialize {
    
    // as dictionary with '___class' label (analog of Android implementation)
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[self retrieveProperties]];
    data[@"___class"] = @"Users";
    [data removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
    
    [DebLog log:@"BackendlessUser -> onAMFSerialize: %@", data];
    
    return data;
}

// overrided method MUST return 'self' to avoid a deserialization breaking
-(id)onAMFDeserialize {
    NSDictionary *props = [Types propertyDictionary:self];
    //[self replaceAllProperties]; // http://bugs.backendless.com/browse/BKNDLSS-12973
    [self assignProperties:props];
    
    [DebLog log:@"BackendlessUser -> onAMFDeserialize: %@", props];
    
    return self;
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
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.NSArray" mapped:[NSArray class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.ObjectProperty" mapped:[ObjectProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.QueryOptions" mapped:[QueryOptions class]];

        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
        [[Types sharedInstance] addClientClassMapping:@"java.lang.ClassCastException" mapped:[ClassCastException class]];
#if !_IS_USERS_CLASS_
        [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
#endif
	
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

#if OLD_ASYNC_WITH_FAULT

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

-(NSArray *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
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

#else

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

-(NSArray<ObjectProperty*> *)describe:(NSString *)classCanonicalName error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self describe:classCanonicalName];
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

-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self save:entityName entity:entity];
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

-(NSDictionary *)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self update:entityName entity:entity sid:sid];
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

-(id)save:(id)entity error:(Fault **)fault {
    
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

-(id)create:(id)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self create:entity];
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

-(id)update:(id)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self update:entity];
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

-(id)load:(id)object relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self load:object relations:relations];
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

-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self load:object relations:relations relationsDepth:relationsDepth];
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

-(NSArray *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self find:entity dataQuery:dataQuery];
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

-(id)first:(Class)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self first:entity];
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

-(id)last:(Class)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self last:entity];
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

-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self first:entity relations:relations relationsDepth:relationsDepth];
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

-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self last:entity relations:relations relationsDepth:relationsDepth];
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

-(id)findByObject:(id)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:entity];
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

-(id)findByObject:(id)entity relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:entity relations:relations];
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

-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:entity relations:relations relationsDepth:relationsDepth];
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

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:className keys:props];
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

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:className keys:props relations:relations];
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

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByObject:className keys:props relations:relations relationsDepth:relationsDepth];
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

-(id)findById:(NSString *)entityName sid:(NSString *)sid error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:entityName sid:sid];
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

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:entityName sid:sid relations:relations];
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

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:entityName sid:sid relations:relations relationsDepth:relationsDepth];
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

-(id)findByClassId:(Class)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findByClassId:entity sid:sid];
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

-(NSNumber *)remove:(id)entity error:(Fault **)fault {
    
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

-(NSNumber *)remove:(Class)entity sid:(NSString *)sid error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self remove:entity sid:sid];
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

-(NSArray *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getView:viewName dataQuery:dataQuery];
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

-(NSArray *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self callStoredProcedure:spName arguments:arguments];
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

-(NSNumber *)getObjectCount:(Class)entity error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getObjectCount:entity];
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

-(NSNumber *)getObjectCount:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getObjectCount:entity dataQuery:dataQuery];
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

//
-(id)createRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self createRelation:parentObject columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
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

//-(id)createRelationForId:(NSString *)parentObjectId columnName:(NSString *)columnName childObjectsIds:(NSArray<NSString*> *)childObjectsIds error:(Fault **)fault {
//    
//    id result = nil;
//    @try {
//        result = [self createRelationForId:parentObjectId columnName:columnName parentObjectId:parentObjectId childObjectsIds:childObjectsIds];
//    }
//    @catch (Fault *fault) {
//        result = fault;
//    }
//    @finally {
//        if ([result isKindOfClass:Fault.class]) {
//            if (fault)(*fault) = result;
//            return nil;
//        }
//        return result;
//    }
//
//}

-(NSNumber *)createRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self createRelation:parentObject columnName:columnName whereClause:whereClause];
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

-(NSNumber *)createRelationForId:(NSString *)parentObjectId columnName:(NSString *)columnName whereClause:(NSString *)whereClause error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self createRelationForId:parentObjectId columnName:columnName whereClause:whereClause];
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

-(id)deleteRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self ddeleteRelation:parentObject columnName:columnName parentObjectId:parentObjectId childObjects:childObjects];
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

-(NSNumber *)deleteRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self deleteRelation:parentObject columnName:columnName parentObjectId:parentObjectId whereClause:whereClause];
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

// sync methods with fault return  (as exception)

-(NSArray<ObjectProperty*> *)describe:(NSString *)classCanonicalName {
    
    if (!classCanonicalName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:classCanonicalName, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args];
}

-(NSDictionary *)save:(NSString *)entityName entity:(NSDictionary *)entity {
    
    if (!entity || !entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, entity, nil];
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
    
    NSArray *args = [NSArray arrayWithObjects:entityName, entity, nil];
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
    if (![objectId isKindOfClass:[NSNumber class]]) {
        return (objectId && [objectId isKindOfClass:[NSString class]]) ? [backendless.persistenceService update:entity] : [backendless.persistenceService create:entity];
    }
    else {
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
#endif
    
    [DebLog log:@"PersistenceService -> save: class = %@, entity = %@", [self objectClassName:entity], [self propertyDictionary:entity]];
    
#if _DIRECTLY_SAVE_METHOD
    NSString *method = METHOD_SAVE;
#else // 'save' = 'create' | 'update'
    id objectId = [self getObjectId:entity];
    BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
    NSString *method = isObjectId?METHOD_UPDATE:METHOD_CREATE;
    [DebLog log:@"PersistenceService -> save: method = %@, objectId = %@", method, objectId];
#endif
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    NSArray *args = @[[self objectClassName:entity], [self propertyDictionary:entity]];
#else
    NSArray *args = @[[self objectClassName:entity], [self propertyObject:entity]];
#endif
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:method args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
    [self onCurrentUserUpdate:result];
#endif
    
    return result;
}

-(id)create:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [DebLog log:@"PersistenceService -> create: class = %@, entity = %@", [self objectClassName:entity], entity];
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    [self prepareObject:entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:[self objectClassName:entity], props, nil];
#else
    NSArray *args = @[[self objectClassName:entity],  [self propertyObject:entity]];
#endif
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
    
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
    [self onCurrentUserUpdate:result];
#endif
    
    return result;
}

-(id)update:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];

    [DebLog log:@"PersistenceService -> update: class = %@, entity = %@", [self objectClassName:entity], entity];
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:[self objectClassName:entity], props, nil];
#else
    NSArray *args = @[[self objectClassName:entity],  [self propertyObject:entity]];
#endif
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if ([OfflineModeManager sharedInstance].isOfflineMode) {
            return [[OfflineModeManager sharedInstance] saveObject:entity];
        }
        return result;
    }
    
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
    [self onCurrentUserUpdate:result];
#endif

    return result;
}

-(id)load:(id)object relations:(NSArray *)relations {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[[self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    return [self setRelations:relations object:object response:result];
}

-(id)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[[self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations, @(relationsDepth)];
    id result = [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    return [self setRelations:relations object:object response:result];
}

-(NSArray *)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], dataQuery, nil];
    id result = [backendlessCache invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args];
#if 1
    return [result isKindOfClass:[Fault class]]? result : [self getAsCollection:result query:dataQuery];
#else
    if (![result isKindOfClass:[Fault class]])
    {
        NSArray *bc = result;
        [bc pageSize:dataQuery.queryOptions.pageSize.integerValue];
        bc.query = dataQuery;
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
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args];
}

-(id)last:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args];
}

-(id)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args];
}

-(id)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args];
}

#define _FIND_BY_INSTANCE_ 0

-(id)findByObject:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
#if _FIND_BY_INSTANCE_
    NSArray *args = @[[self objectClassName:entity], entity];
#else
    NSArray *args = @[[self objectClassName:entity], [self propertyDictionary:entity]];
#endif
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(id)entity relations:(NSArray *)relations {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
#if _FIND_BY_INSTANCE_
    NSArray *args = @[[self objectClassName:entity], entity, relations];
#else
    NSArray *args = @[[self objectClassName:entity], [self propertyDictionary:entity], relations];
#endif
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entity)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
#if _FIND_BY_INSTANCE_
    NSArray *args = @[[self objectClassName:entity], entity, relations, @(relationsDepth)];
#else
    NSArray *args = @[[self objectClassName:entity], [self propertyDictionary:entity], relations, @(relationsDepth)];
#endif
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[className, props];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[className, props, relations];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!className)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!props)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = @[className, props, relations, @(relationsDepth)];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, relations, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth {
    
    if (!entityName)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, relations, @(relationsDepth), nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(id)findByClassId:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args];
}

-(NSNumber *)remove:(id)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self objectClassName:entity], entity];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
}

-(NSNumber *)remove:(Class)entity sid:(NSString *)sid {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    if (!sid)
        return [backendless throwFault:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], sid, nil];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args];
}

-(NSArray *)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!viewName)
        return [backendless throwFault:FAULT_NAME_IS_NULL];
    
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    
    NSArray *args = @[viewName, dataQuery];
    id result = [backendlessCache invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CALL_STORED_VIEW args:args];
    return [result isKindOfClass:[Fault class]]? result : [self getAsCollection:result query:dataQuery];
}

-(NSArray *)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments {
    
    if (!spName)
        return [backendless throwFault:FAULT_NAME_IS_NULL];
    
    if (!arguments) arguments = [NSDictionary dictionary];
    
    NSArray *args = @[spName, arguments];
    return [backendlessCache invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CALL_STORED_PROCEDURE args:args];
}

-(NSNumber *)getObjectCount:(Class)entity {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self typeClassName:entity]];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args];
}

-(NSNumber *)getObjectCount:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery {
    
    if (!entity)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self typeClassName:entity], dataQuery?dataQuery:BACKENDLESS_DATA_QUERY];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args];
}

-(id)createRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    if (!parentObject)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, childObjects];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:CREATE_RELATION args:args];
   
}

//-(id)createRelationForId:(NSString *)parentObjectId columnName:(NSString *)columnName childObjectsIds:(NSArray<NSString*> *)childObjectsIds {
//    return nil;
//}

-(NSNumber *)createRelation:(id)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause {
    if (!parentObject)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, whereClause];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:CREATE_RELATION args:args];
}

-(id)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects {
    if (!parentObject)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, childObjects];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:DELETE_RELATION args:args];
}

-(NSNumber *)deleteRelation:(NSString *)parentObject columnName: (NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause {
    if (!parentObject)
        return [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, whereClause];
    return [invoker invokeSync:SERVER_PERSISTENCE_SERVICE_PATH method:DELETE_RELATION args:args];
}

// async methods with block-base callbacks

-(void)describe:(NSString *)classCanonicalName response:(void(^)(NSArray<ObjectProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    
    if (!classCanonicalName)
    return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(classCanonicalName)];
    NSArray *args = [NSArray arrayWithObjects:classCanonicalName, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_DESCRIBE args:args responder:chainedResponder];
}

-(void)save:(NSString *)entityName entity:(NSDictionary *)entity response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity || !entityName)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, entity, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        
        Responder *offlineModeResponder = [Responder responder:chainedResponder selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = chainedResponder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:chainedResponder];
}

-(void)update:(NSString *)entityName entity:(NSDictionary *)entity sid:(NSString *)sid response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity || !entityName){ return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!sid) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = [NSArray arrayWithObjects:entityName, entity, nil];
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        
        Responder *offlineModeResponder = [Responder responder:chainedResponder selResponseHandler:nil selErrorHandler:@selector(failWithOfflineMode:)];
        offlineModeResponder.chained = chainedResponder;
        offlineModeResponder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:offlineModeResponder];
    }
    else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:chainedResponder];
}

-(void)save:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
#if OLD_SAVE_METHOD_ON
    id objectId = [self getObjectId:entity];
    if (![objectId isKindOfClass:[NSNumber class]]) {
        return (objectId && [objectId isKindOfClass:[NSString class]]) ?
        [backendless.persistenceService update:entity responder:chainedResponder] : [backendless.persistenceService create:entity responder:chainedResponder];
    }
    else {
        return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    }
#endif
    
    [DebLog log:@"PersistenceService -> save: class = %@, entity = %@", [self objectClassName:entity], [self propertyDictionary:entity]];
    
#if _DIRECTLY_SAVE_METHOD
    NSString *method = METHOD_SAVE;
#else // 'save' = 'create' | 'update'
    id objectId = [self getObjectId:entity];
    BOOL isObjectId = objectId && [objectId isKindOfClass:NSString.class];
    NSString *method = isObjectId?METHOD_UPDATE:METHOD_CREATE;
    [DebLog log:@"PersistenceService -> save: method = %@, objectId = %@", method, objectId];
#endif
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    NSArray *args = @[[self objectClassName:entity], [self propertyDictionary:entity]];
#else
    NSArray *args = @[[self objectClassName:entity],  [self propertyObject:entity]];
#endif
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:@selector(failWithOfflineMode:)];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:method args:args responder:_responder];
    }
    else {
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:nil];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:method args:args responder:_responder];
    }
}

-(void)create:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    [self prepareObject:entity];
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:[self objectClassName:entity], props, nil];
#else
    NSArray *args = @[[self objectClassName:entity],  [self propertyObject:entity]];
#endif
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:@selector(failWithOfflineMode:)];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:_responder];
    }
    else {
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:nil];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CREATE args:args responder:_responder];
    }
}

-(void)update:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
#if _SAVE_OBJECT_AS_DICTIONARY_
    NSDictionary *props = [self filteringProperty:entity];
    NSArray *args = [NSArray arrayWithObjects:[self objectClassName:entity], props, nil];
#else
    NSArray *args = @[[self objectClassName:entity],  [self propertyObject:entity]];
#endif
    if ([OfflineModeManager sharedInstance].isOfflineMode) {
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:@selector(failWithOfflineMode:)];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:_responder];
    }
    else {
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
        Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(createResponse:) selErrorHandler:nil];
        _responder.chained = chainedResponder;
        _responder.context = entity;
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:_responder];
#else
        [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_UPDATE args:args responder:chainedResponder];
#endif
    }
}

-(void)load:(id)object relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[[self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations];
    Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(loadRelations:) selErrorHandler:nil];
    _responder.chained = chainedResponder;
    _responder.context = @{@"object":object, @"relations":relations};
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args responder:_responder];
}

-(void)load:(id)object relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSString *objectId = [self getObjectId:object];
    NSArray *args = @[[self objectClassName:object], [objectId isKindOfClass:[NSString class]]?objectId:object, relations, @(relationsDepth)];
    Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(loadRelations:) selErrorHandler:nil];
    _responder.chained = chainedResponder;
    _responder.context = @{@"object":object, @"relations":relations};
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LOAD args:args responder:_responder];
}

-(void)find:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    [self prepareClass:entity];
    if (!dataQuery) { dataQuery = BACKENDLESS_DATA_QUERY; }
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], dataQuery, nil];
    Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(setCurrentPageSize:) selErrorHandler:nil];
    _responder.context = dataQuery;
    _responder.chained = chainedResponder;
    [backendlessCache invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIND args:args responder:_responder];
}

-(void)first:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:chainedResponder];
}

-(void)last:(Class)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:chainedResponder];
}

-(void)first:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FIRST args:args responder:chainedResponder];
}

-(void)last:(Class)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_LAST args:args responder:chainedResponder];
}

-(void)findByObject:(id)entity response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = @[[self objectClassName:entity], entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findByObject:(id)entity relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = @[[self objectClassName:entity],entity, relations];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
    
}

-(void)findByObject:(id)entity relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = @[[self objectClassName:entity], entity, relations, @(relationsDepth)];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!className) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!props) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = [NSArray arrayWithObjects:className, props, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!className) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!props) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = [NSArray arrayWithObjects:className, props, relations, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findByObject:(NSString *)className keys:(NSDictionary *)props relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!className) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!props) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    NSArray *args = [NSArray arrayWithObjects:className, props, relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entityName) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!sid) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entityName)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, relations, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findById:(NSString *)entityName sid:(NSString *)sid relations:(NSArray *)relations relationsDepth:(int)relationsDepth response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entityName) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!sid) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    [self prepareClass:NSClassFromString(entityName)];
    NSArray *args = [NSArray arrayWithObjects:entityName, sid, relations, @(relationsDepth), nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)findByClassId:(Class)entity sid:(NSString *)sid response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity) { return [chainedResponder errorHandler:FAULT_NO_ENTITY]; }
    
    if (!sid) { return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST]; }
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_FINDBYID args:args responder:chainedResponder];
}

-(void)remove:(id)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity)
    return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self objectClassName:entity], entity];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:chainedResponder];
}

-(void)remove:(Class)entity sid:(NSString *)sid response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    if (!sid)
        return [chainedResponder errorHandler:FAULT_OBJECT_ID_IS_NOT_EXIST];
    
    [self prepareClass:entity];
    NSArray *args = [NSArray arrayWithObjects:[self typeClassName:entity], sid, nil];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_REMOVE args:args responder:chainedResponder];
}

-(void)getView:(NSString *)viewName dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!viewName)
        return [chainedResponder errorHandler:FAULT_NAME_IS_NULL];
    
    if (!dataQuery) dataQuery = BACKENDLESS_DATA_QUERY;
    
    NSArray *args = @[viewName, dataQuery];
    Responder *_responder = [Responder responder:chainedResponder selResponseHandler:@selector(setCurrentPageSize:) selErrorHandler:nil];
    _responder.context = dataQuery;
    _responder.chained = chainedResponder;
    [backendlessCache invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CALL_STORED_VIEW args:args responder:_responder];
}

-(void)callStoredProcedure:(NSString *)spName arguments:(NSDictionary *)arguments response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!spName)
        return [chainedResponder errorHandler:FAULT_NAME_IS_NULL];
    
    if (!arguments) arguments = [NSDictionary dictionary];
    
    NSArray *args = @[spName, arguments];
    [backendlessCache invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_CALL_STORED_PROCEDURE args:args responder:chainedResponder];
}

-(void)getObjectCount:(Class)entity response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self typeClassName:entity]];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args responder:chainedResponder];
}

-(void)getObjectCount:(Class)entity dataQuery:(BackendlessDataQuery *)dataQuery response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!entity)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[[self typeClassName:entity], dataQuery?dataQuery:BACKENDLESS_DATA_QUERY];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:METHOD_COUNT args:args responder:chainedResponder];
}

-(void)createRelation:(id)parentObject columnName: (NSString *)columnName childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
}
-(void)createRelationForId:(NSString *)parentObjectId columnName:(NSString *)columnName childObjectsIds:(NSArray<NSString*> *)childObjectsIds response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
}
-(void)createRelation:(id)parentObject columnName: (NSString *)columnName whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    
}
-(void)createRelationForId:(NSString *)parentObjectId columnName:(NSString *)columnName whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    
}
-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId childObjects:(NSArray *)childObjects response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!parentObject)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, childObjects];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:DELETE_RELATION args:args responder:chainedResponder];
}

-(void)deleteRelation:(NSString *)parentObject columnName:(NSString *)columnName parentObjectId:(NSString *)parentObjectId whereClause:(NSString *)whereClause response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!parentObject)
        return [chainedResponder errorHandler:FAULT_NO_ENTITY];
    
    NSArray *args = @[parentObject, columnName, parentObjectId, whereClause];
    [invoker invokeAsync:SERVER_PERSISTENCE_SERVICE_PATH method:DELETE_RELATION args:args responder:chainedResponder];
}



// IDataStore class factory

-(id <IDataStore>)of:(Class)entityClass {
    return [DataStoreFactory createDataStore:entityClass];
}

// MapDrivenDataStore factory
-(MapDrivenDataStore *)ofTable:(NSString *)tableName {
    return [MapDrivenDataStore createDataStore:tableName];
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

-(void)mapTableToClass:(NSString *)tableName type:(Class)type {
    [[Types sharedInstance] addClientClassMapping:tableName mapped:type];
}


#if 0
-(void)removeAllSync:(Class)entity {
    
    if (!entity)
        [backendless throwFault:FAULT_NO_ENTITY];
    
    NSArray *bc = [backendless.persistenceService find:entity dataQuery:nil];
    
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

-(void)removeAllPagesAsync:(NSArray *)bc {
    
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
        [bc nextPageAsync:^(NSArray *bc) {
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

-(NSDictionary *)filteringProperty:(id)object {
    return [self propertyDictionary:object];
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
    id object = [__types classInstance:className];
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
#if FILTRATION_USER_TOKEN_ON
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[(BackendlessUser *)object retrieveProperties]];
        [data removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
        return data;
#else
        return [(BackendlessUser *)object retrieveProperties];
#endif
    }
    return [Types propertyDictionary:object];
}

-(id)propertyObject:(id)object {
    
    if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
#if FILTRATION_USER_TOKEN_ON
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[(BackendlessUser *) object retrieveProperties]];
        [data removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
        return data;
#else
        return [(BackendlessUser *)object retrieveProperties];
#endif
    }
    
    return object;
}


-(NSArray *)getAsCollection:(id)data query:(BackendlessDataQuery *)query {
    
    NSArray *collection = nil;
    
    if ([data isKindOfClass:[NSArray class]]) {
        collection = data;
    }
    else if ([data isKindOfClass:[NSDictionary class]]) {
        collection = [[NSArray new] autorelease];
        [collection resolveProperties:data];
    }

    [DebLog logN:@"PersistenceService -> getAsCollection: %@ -> \n%@", data, collection];
    
    return collection;
}

-(id)setRelations:(NSArray *)relations object:(id)object response:(id)response {
#if 0
    for (NSString *propertyName in relations) {
#else
    NSArray *keys = [response allKeys];
    for (NSString *propertyName in keys) {
#endif
        
        id value = [response valueForKey:propertyName];
        if ([value isKindOfClass:[NSNull class]]) {
            continue;
        }
        
        if ([[object class] isSubclassOfClass:[BackendlessUser class]]) {
            [(BackendlessUser *)object setProperty:propertyName object:value];
            continue;
        }
        
        [object setValue:value forKey:propertyName];
    }
    
    return object;
}

#pragma mark -
#pragma mark Callback Methods

-(id)setCurrentPageSize:(ResponseContext *)response {
    return [self getAsCollection:response.response query:response.context];
}

-(id)loadRelations:(ResponseContext *)response {
    
    NSArray *relations = [response.context valueForKey:@"relations"];
    id object = [response.context valueForKey:@"object"];
    
    return [self setRelations:relations object:object response:response.response];
}

-(id)createResponse:(ResponseContext *)response {
    
    id object = response.context;
    if ([[object class] isSubclassOfClass:[NSManagedObject class]]) {
        [__types.managedObjectContext deleteObject:object];
    }
    
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
    [self onCurrentUserUpdate:response.response];
#endif

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
    
#if _PERSISTENCE_UDPATE_CURRENTUSER_ON_
-(id)onCurrentUserUpdate:(id)result {
    
    if (![result isKindOfClass:[BackendlessUser class]]) {
        return result;
    }
    
    BackendlessUser *user = (BackendlessUser *)result;
    if (backendless.userService.isStayLoggedIn && backendless.userService.currentUser && [user.objectId isEqualToString:backendless.userService.currentUser.objectId]) {
        backendless.userService.currentUser = user;
        [backendless.userService setPersistentUser];
    }
    
    return user;
}
#endif

@end
