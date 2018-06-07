//
//  NamedObject.m
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

#import "NamedObject.h"
#import "DEBUG.h"
#import "Types.h"
#import "ITypeReader.h"

@implementation NamedObject

-(id)initWithName:(NSString *)name andObject:(id <IAdaptingType>)object {
    if (self = [super init]) {
        objectName = name;
        typedObject = object;
        // mapped type priority
        if (!(mappedType = [__types getServerTypeForClientClass:objectName]))
            mappedType = [__types classByName:objectName];
    }
    return self;
}

+(id)objectType:(NSString *)name withObject:(id <IAdaptingType>)object {
    return [[[NamedObject alloc] initWithName:name andObject:object] autorelease];
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC NamedObject"];
    [super dealloc];
}

#pragma mark -
#pragma mark ICacheableAdaptingType Methods

-(Class)getDefaultType {
    return (mappedType) ? mappedType : [typedObject getDefaultType];
}

-(id)defaultAdapt {
    return [self defaultAdapt:[ReaderReferenceCache cache]];
}

-(id)defaultAdapt:(ReaderReferenceCache *)refCache {
    [DebLog log:_ON_READERS_LOG_ text:@"NamedObject -> defaultAdapt: objectName = '%@', typedObject = '%@', mappedType = '%@', refCache = %@", objectName, typedObject, mappedType, refCache];
    if (mappedType) {
        if ([typedObject conformsToProtocol:@protocol(ICacheableAdaptingType)]) {
            return [(id <ICacheableAdaptingType>)typedObject adapt:mappedType cache:refCache];
        }
        else {
            return [typedObject adapt:mappedType];
        }
    }
    else {
        if ([typedObject conformsToProtocol:@protocol(ICacheableAdaptingType)]) {
            return [(id <ICacheableAdaptingType>)typedObject defaultAdapt:refCache];
        }
        else {
            return [typedObject defaultAdapt];
        }
    }
}

-(id)adapt:(Class)type {
    return [self adapt:type cache:[ReaderReferenceCache cache]];
}

-(id)adapt:(Class)type cache:(ReaderReferenceCache *)refCache {
    [DebLog log:_ON_READERS_LOG_ text:@"NamedObject -> adapt: objectName = '%@', typedObject = '%@', mappedType = '%@'", objectName, typedObject, mappedType];
    if (mappedType && [mappedType isSubclassOfClass:type]) {
        if ([typedObject conformsToProtocol:@protocol(ICacheableAdaptingType)])
            return [(id <ICacheableAdaptingType>)typedObject adapt:mappedType cache:refCache];
        else
            return [typedObject adapt:mappedType];
    }
    else {
        if ([typedObject conformsToProtocol:@protocol(ICacheableAdaptingType)])
            return [(id <ICacheableAdaptingType>)typedObject adapt:type cache:refCache];
        else
            return [typedObject adapt:type];
    }
}

-(id <IAdaptingType>)getCacheKey {
    return typedObject;
}

-(BOOL)canAdapt:(Class)formalArg {
    if ([formalArg isSubclassOfClass:[NSDictionary class]])
        return YES;
    if (mappedType)
        return [mappedType isSubclassOfClass:formalArg];
    return [objectName isEqualToString:[Types typeClassName:formalArg]];
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
    return NO;
}

-(Class)getMappedType {
    return mappedType;
}

@end
