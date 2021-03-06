//
//  ArrayType.m
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

#import "ArrayType.h"
#import "DEBUG.h"
#import "Types.h"
#import "ITypeReader.h"


@implementation ArrayType

-(id)initWithArray:(NSArray *)data
{	
	if ( (self=[super init]) ) {
		arrayObject = data;
	}
	
	return self;
}

+(id)objectType:(NSArray *)data
{
	return [[[ArrayType alloc] initWithArray:data] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ArrayType"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSArray *)getArray {
	return arrayObject;    
}

#pragma mark -
#pragma mark IAdaptingType Methods

-(Class)getDefaultType {
	return [arrayObject class];
}

-(id)defaultAdapt {
	
	[DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> defaultAdapt (1)"];
  	
    return [self defaultAdapt:[ReaderReferenceCache cache]];  
}

-(id)defaultAdapt:(ReaderReferenceCache *)refCache {
    
    [DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> defaultAdapt (2) refCache = %@", refCache];
    
    if ([refCache hasObject:self]) {
        [DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> defaultAdapt (HAS OBJ FOR SELF) %@", self];
        return [refCache getObject:self];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    [refCache addObject:self object:array];
    
    for (id obj in arrayObject) {
        
        if ([obj conformsToProtocol:@protocol(ICacheableAdaptingType)]) {
            
            if ([refCache hasObject:obj]) {
                [DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> defaultAdapt (HAS OBJ FOR OBJ) %@", obj];
                obj = [refCache getObject:obj];
            }
            else {
                
                id val = [obj defaultAdapt];
                [refCache addObject:obj object:val];
                obj = val;
            }
         }
        else {
            if ([obj conformsToProtocol:@protocol(IAdaptingType)])
                obj  = [obj defaultAdapt];
        }
        
        if (!obj) obj = [NSNull null];
        [array addObject:obj];
    }
    
    return array;
}

-(id)adapt:(Class)type {
	
    [DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> adapt: %@", type];
    
    return [self adapt:type cache:[ReaderReferenceCache cache]];
}

-(id)adapt:(Class)type cache:(ReaderReferenceCache *)refCache {
    
    [DebLog log:_ON_READERS_LOG_ text:@"ArrayType -> adapt: %@ cache: %@", type, refCache];
    
    if ([refCache hasObject:self type:type])
        return [refCache getObject:self type:type];
    
    if ([type conformsToProtocol:@protocol(IAdaptingType)]) {
        [DebLog logN:@"ArrayType -> adapt: type %@ is an adapting type", type];
        return self;
    }
    
    if ([type isSubclassOfClass:[NSArray class]]) {
        NSArray *array = [self defaultAdapt:refCache];
        [DebLog logN:@"ArrayType -> adapt: type %@ is an array:\n%@", type, array];
        return array;
    }
    
    if ([type isSubclassOfClass:[NSSet class]]) {
        NSArray *array = [self defaultAdapt:refCache];
        [DebLog logN:@"ArrayType -> adapt: type %@ is a set%\n%@", type, array];
        return [NSSet setWithArray:array];
    }

    [DebLog logY:@"ArrayType -> adapt: type %@ CAN NOT ADAPT! (= defaultAdapt)", type];
         
    return [self defaultAdapt:refCache];
}

-(id <IAdaptingType>)getCacheKey {
    return self;
}

-(BOOL)canAdapt:(Class)formalArg {
	return NO;
}

-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs {
	return NO;
}

@end
