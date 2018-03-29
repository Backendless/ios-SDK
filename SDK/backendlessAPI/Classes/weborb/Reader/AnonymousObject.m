//
//  AnonymousObject.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ITypeReader.h"
#import "AnonymousObject.h"
#import "DEBUG.h"
#import "Types.h"
#import "ObjectFactories.h"
#import "BinaryStream.h"
#import "V3Message.h"
#import "NamedObject.h"
#import "ArrayType.h"
#import "BodyHolder.h"
#import "BackendlessUserAdapter.h"

@implementation AnonymousObject
@synthesize properties;

-(id)init {
    if (self = [super init]) {
        self.properties = [NSMutableDictionary dictionary];
    }
    return self;
}

-(id)initWithNode:(NSMutableDictionary *)dictionary {
    if (self = [super init]) {
        self.properties = dictionary;
    }
    return self;
}

+(id)objectType {
    return [[[AnonymousObject alloc] init] autorelease];
}

+(id)objectType:(NSMutableDictionary *)dictionary {
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> (#######) +(id)objectType: PROPERTIES: %@", dictionary];
    return [[[AnonymousObject alloc] initWithNode:dictionary] autorelease];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC AnonymousObject"];
    [super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(Class)propertyType:(NSString *)attributes {
    const char *attr = [attributes UTF8String];
    if (attr[0] != 'T' || attr[1] != '@') {
        return [NSNull class];
    }
    if (attr[2] == ',') {
        return [NSObject class];
    }
    if (attr[2] == '"') {
        size_t length = attributes.length;
        for (int i = 3; i < length; i++) {
            if (attr[i] == '"') {
                size_t count = i - 3;
                if (count == 0)
                    break;
                char *buffer = malloc(count+1);
                memmove(buffer, &attr[3], count);
                buffer[count] = 0;
                Class type = [__types classByName:[NSString stringWithUTF8String:buffer]];
                free(buffer);
                return (type) ? type : [NSObject class];
            }
        }
    }
    return [NSObject class];
}

-(char)propertyCode:(NSString *)attributes {
    const char *attr = [attributes UTF8String];
    return (attributes && (attributes.length > 1) && attr[0] == 'T') ? attr[1] : 0;
}

-(id)propertyValue:(id)obj {
    return [obj conformsToProtocol:@protocol(IAdaptingType)] ? [obj defaultAdapt] : nil;
}

-(id)setFieldsDirect:(id)obj cache:(ReaderReferenceCache *)referenceCache {
    NSDictionary *props = [Types propertyDictionary:obj];
    NSDictionary *attrs = [Types propertyKeysWithAttributes:obj];
    NSArray *names = [props allKeys];
    [DebLog log:_ON_READERS_LOG_ text:@"\n\n\nAnonymousObject -> setFieldsDirect: START obj <%@> props = %@\n properties = %@", [obj class], props, properties];
    
    for (NSString *memberName in names) {
        id prop = [props valueForKey:memberName];
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: PROPERTY %@ <%@>", memberName, [prop class]];
        id propValue = [properties valueForKey:memberName];
        
        // field to property mapping
        if ([propValue isKindOfClass:[NamedObject class]]) {
            ((AnonymousObject *)[propValue getCacheKey]).properties = [self mapFieldToProperty:propValue];
        }
        else if ([propValue isKindOfClass:[ArrayType class]]) {
            for (id propObject in [propValue getArray]) {
                if ([propObject isKindOfClass:[NamedObject class]]) {
                    ((AnonymousObject *)[propObject getCacheKey]).properties = [self mapFieldToProperty:propObject];
                }
            }
        }
    
        // BackendlessUser adaptation (for relations)
        if ([propValue isKindOfClass:[ArrayType class]]) {
            NSMutableArray *newPropValueArray = [NSMutableArray new];
            for (id propObject in [propValue getArray]) {
                [newPropValueArray addObject:[self checkAndAdaptToBackendlessUser:propObject]];
            }
            if ([newPropValueArray count] > 0) {
                propValue = [ArrayType objectType:newPropValueArray];
            }
        }
        else {
            propValue = [self checkAndAdaptToBackendlessUser:propValue];
        }
        
        if (!propValue) {
            // and with uppercased first char of property name?
            NSString *upper = [memberName firstCharToUpper];
            propValue = [properties valueForKey:upper];
            [DebLog logN:@"AnonymousObject -> setFieldsDirect: (upper) %@ = %@", upper, propValue];
        }
        if (!propValue || [propValue isKindOfClass:[NSNull class]]) {
            [DebLog logN:@"AnonymousObject -> setFieldsDirect: PROPERTY %@ WAS NOT FOUND, propValue = %@", memberName, propValue];
            continue;
        }
        NSString *attributes = [attrs valueForKey:memberName];
        Class propertyType = [self propertyType:attributes];
        char propertyCode = [self propertyCode:attributes];
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: '%@' NEED ADAPT %@ <%@> TO <%@> [%@] {%c}", memberName, propValue, [propValue class], propertyType, attributes, propertyCode];
        if (propertyCode == '@') {
            if ([propValue conformsToProtocol:@protocol(IAdaptingType)]) {
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: @protocol(IAdaptingType)"];
                id val = [[ObjectFactories sharedInstance] createArgumentObjectByType:propertyType argument:propValue];
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (0) val = %@", val];
                if (val) {
                    [referenceCache addObject:propValue type:propertyType object:val];
                    propValue = val;
                    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (1) propValue = %@", propValue];
                }
                else {
                    if ([propValue conformsToProtocol:@protocol(ICacheableAdaptingType)]) {
                        propValue = [propValue adapt:propertyType cache:referenceCache];
                        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (2) propValue = %@", propValue];
                    }
                    else {
                        propValue = [propValue adapt:propertyType];
                        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (3) propValue = %@", propValue];
                    }
                }
            }
            else {
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (4) propValue = %@, propertyType = %@", propValue, propertyType];
                if ([propValue isKindOfClass:[NSArray class]] && (propertyType == [NSSet class])) {
                    propValue = [NSSet setWithArray:propValue];
                    [DebLog logN:@"AnonymousObject -> setFieldsDirect: ***** NSSet from NSArray ******"];
                }
            }
        }
        else {
            if ([propValue conformsToProtocol:@protocol(IAdaptingType)]) {
                propValue = propertyCode? [propValue adapt:propertyType] : [propValue defaultAdapt];
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (5) propValue = %@ [%d]", propValue, (int)propertyCode];
            }
            else {
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (6) propValue = %@", propValue];
            }
        }
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: %@ [%c] SET %@ <%@>", memberName, propertyCode, propValue, [propValue class]];
        if (propValue && ![propValue isKindOfClass:[NSNull class]]) {
            @try {
                [obj setValue:propValue forKey:memberName];
            }
            @catch (NSException *exception) {
                [DebLog logY:@"AnonymousObject -> setFieldsDirect: <%@> %@ <%@> EXCEPTION = %@", [obj class], memberName, [propValue class], exception];
            }
        }
    }
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: (!!!!!!) SET ALL PROPERTIES obj = %@ <%@>", obj, [obj class]];
#if _ON_RESOLVING_ABSENT_fPROPERTY_
    // add "on the fly" properties to obj
    NSArray *_properties = [properties allKeys];
    for (NSString *prop in _properties) {
        if ([names containsObject:prop]) {
            [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: RESOLVED PROPERTY '%@'->%@", prop, [properties valueForKey:prop]];
            continue;
        }
        id propertyValue = [properties valueForKey:prop];
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: NEED TO RESOLVE '%@'[%@]", prop, [propertyValue description]];
        id value = [self propertyValue:propertyValue];
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: PROPERTY '%@' OF CLASS %@ -> %@ <%@>", prop, [propertyValue class], value, [value class]];
        [obj resolveProperty:prop value:value];
    }
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: FINISHED (0) obj = %@ <%@>\n%@\n\n", obj, [obj class], [Types propertyDictionary:obj]];
#endif
    
    // deserializer pastprocessor
#if TYPES_AMF_DESERIALIZE_POSTPROCESSOR_ON
    if ([obj isKindOfClass:[V3Message class]]) {
        V3Message *v3 = (V3Message *)obj;
        v3.body.body = [Types pastAMFDeserialize:v3.body.body];
    }
    else {
        obj = [Types pastAMFDeserialize:obj];
    }
#else
    if ([obj isKindOfClass:[V3Message class]]) {
        V3Message *v3 = (V3Message *)obj;
        v3.body.body = [v3.body.body onAMFDeserialize];
    }
    else {
        obj = [obj onAMFDeserialize];
    }
#endif
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> setFieldsDirect: FINISHED (1) obj = %@ <%@>\n%@\n\n\n", obj, [obj class], [Types propertyDictionary:obj]];
    return obj;
}

-(NSMutableDictionary *)mapFieldToProperty:(NamedObject *)propValue {
    NSMutableDictionary *propertiesOfPropValue = ((AnonymousObject *)[propValue getCacheKey]).properties;
    if ([[Types sharedInstance] getPropertiesMappingForClientClass:([propValue getMappedType])]) {
        NSDictionary *mappedProperties = [[Types sharedInstance] getPropertiesMappingForClientClass:[propValue getMappedType]];
        NSMutableDictionary *changedPropertiesOfPropValue = [NSMutableDictionary new];
        for (NSString *key in [propertiesOfPropValue allKeys]) {
            if ([[mappedProperties allKeys] containsObject:key]) {
                [changedPropertiesOfPropValue setObject:[propertiesOfPropValue valueForKey:key] forKey:[mappedProperties valueForKey:key]];
            }
            else {
                [changedPropertiesOfPropValue setObject:[propertiesOfPropValue valueForKey:key] forKey:key];
            }
        }
        if (changedPropertiesOfPropValue) {
            return changedPropertiesOfPropValue;
        }
    }
    return propertiesOfPropValue;
}

-(id)checkAndAdaptToBackendlessUser:(id)namedObject {
    if ([namedObject isKindOfClass:[NamedObject class]]) {
        id classTypeString = [((AnonymousObject *)[namedObject getCacheKey]).properties valueForKey:@"___class"];
        if ([[classTypeString defaultAdapt] isEqualToString:@"Users"]) {
            BackendlessUser *user = [[BackendlessUserAdapter new] adaptToBackendlessUser:namedObject];
            return user;
        }
    }
    return namedObject;
}

#pragma mark -
#pragma mark ICacheableAdaptingType Methods

-(Class)getDefaultType {
    return [properties class];
}

-(id)defaultAdapt {
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> defaultAdapt (0)"];
    return [self defaultAdapt:[ReaderReferenceCache cache]];
}

-(id)defaultAdapt:(ReaderReferenceCache *)refCache {
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> defaultAdapt: (1) refCache = %@", refCache];
    if ([refCache hasObject:self]) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> defaultAdapt: (2) refCache has %@", self];
        return [refCache getObject:self];
    }
    NSMutableDictionary *hashtable = [NSMutableDictionary dictionary];
    [refCache addObject:self object:hashtable];
    NSArray *keys = [properties allKeys];
    for (id key in keys) {
        id obj = [properties objectForKey:key];
        if ([obj conformsToProtocol:@protocol(ICacheableAdaptingType)]) {
            if ([refCache hasObject:obj]) {
                [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> defaultAdapt (CASHED) %@", obj];
                obj = [refCache getObject:obj];
            }
            else {
                id val = [obj defaultAdapt:refCache];
                [refCache addObject:obj object:val];
                obj = val;
            }
        }
        else {
            if ([obj conformsToProtocol:@protocol(IAdaptingType)])
                obj  = [obj defaultAdapt];
        }
        if (!obj) obj = [NSNull null];
        [hashtable setObject:obj forKey:key];
    }
    return hashtable;
}

-(id)adapt:(Class)type {
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt: %@", type];
    return [self adapt:type cache:[ReaderReferenceCache cache]];
}

-(id)adapt:(Class)type cache:(ReaderReferenceCache *)refCache {
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (START) type = %@", type];
    id obj = [refCache getObject:self type:type];
    if (obj) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (FINISHED) refCache: type = %@, obj = %@", type, obj];
        return obj;
    }
    obj = [[ObjectFactories sharedInstance] createArgumentObjectByType:type argument:self];
    if (obj) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (FINISHED) createArgumentObjectByType:%@, obj = %@", type, obj];
        [refCache addObject:self type:type object:obj];
        return obj;
    }
    if ([type conformsToProtocol:@protocol(IAdaptingType)]) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (FINISHED) type %@ is an adapting type!", type];
        [refCache addObject:self type:type object:obj];
        return self;
    }
    if ([type isSubclassOfClass:[NSArray class]]) {
        // TODO: for array ???
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (FINISHED) type is an array! *** TODO ***"];
        return [NSMutableArray array];
    }
    obj = [[ObjectFactories sharedInstance] createServiceObjectByType:type];
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: [ObjectFactories createServiceObjectByType:%@] = %@", type, [obj class]];
    if (!obj) obj = [NSDictionary dictionary];
    @try {
        [refCache addObject:self type:type object:obj];
    }
    @catch (NSException *exception) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (EXCEPTION) %@", exception];
    }
    if ((obj) && [obj isKindOfClass:[NSDictionary class]]) {
        [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: type is a dictionary!"];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        NSArray *keys = [properties allKeys];
        for (id key in keys) {
            id valueObj = [properties objectForKey:key];
            if ([valueObj conformsToProtocol:@protocol(ICacheableAdaptingType)])
                valueObj = [valueObj defaultAdapt:refCache];
            else
                valueObj = [valueObj defaultAdapt];
            if (!valueObj) valueObj = [NSNull null];
            [dictionary setObject:valueObj forKey:key];
        }
        obj = dictionary;
    }
    else {
        obj = [self setFieldsDirect:obj cache:refCache];
    }
    [DebLog log:_ON_READERS_LOG_ text:@"AnonymousObject -> adapt:cache: (FINISHED) type = %@, obj = %@", type, obj];
    return obj;
}

-(id <IAdaptingType>)getCacheKey {
    return self;
}

-(BOOL)canAdapt:(Class)formalArg {
    return YES;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
    return NO;
}

@end
