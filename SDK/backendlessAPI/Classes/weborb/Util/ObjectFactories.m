//
//  ObjectFactories.m
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

#import "ObjectFactories.h"
#import "DEBUG.h"
#import "Types.h"


@implementation ObjectFactories

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(ObjectFactories *)sharedInstance {
	static ObjectFactories *sharedObjectFactories;
	@synchronized(self)
	{
		if (!sharedObjectFactories)
			sharedObjectFactories = [[ObjectFactories alloc] init];
	}
	return sharedObjectFactories;
}

-(id)init {	
	if ( (self=[super init]) ) {
		serviceObjectFactories = [[NSMutableDictionary alloc] init];
		argumentObjectFactories = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ObjectFactories"];
	
	[serviceObjectFactories removeAllObjects];
	[serviceObjectFactories release];
	
	[argumentObjectFactories removeAllObjects];
	[argumentObjectFactories release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(id)createArgumentObject:(NSString *)className argument:(id <IAdaptingType>)argument {
    
    if (!className)
        return nil;
    
    id <IArgumentObjectFactory> factory = [argumentObjectFactories valueForKey:className];
    return (factory) ? [factory createObject:argument] : nil;
}

#pragma mark -
#pragma mark Public Methods

-(id)createServiceObjectByName:(NSString *)className {
    
    if (!className)
        return nil;
    
    id <IServiceObjectFactory> factory = [serviceObjectFactories valueForKey:className];
    return (factory) ? [factory createObject] : [Types classInstanceByClassName:className];
}

-(id)createServiceObjectByType:(Class)type {
    
    if (!type)
        return nil;
    
    NSString *className = [Types typeClassName:type];
    id <IServiceObjectFactory> factory = (className) ? [serviceObjectFactories valueForKey:className] : nil;
    return (factory) ? [factory createObject] : [__types classInstance:type];
}

-(id)createArgumentObjectByName:(NSString *)className argument:(id <IAdaptingType>)argument {
    return [self createArgumentObject:className argument:argument];
}

-(id)createArgumentObjectByType:(Class)type argument:(id <IAdaptingType>)argument {
    return [self createArgumentObject:[Types typeClassName:type] argument:argument];
}

-(void)addServiceObjectFactory:(NSString *)typeName factory:(id <IServiceObjectFactory>)objectFactory {
    [serviceObjectFactories setValue:objectFactory forKey:typeName];
}

-(void)addArgumentObjectFactory:(NSString *)typeName factory:(id <IArgumentObjectFactory>)objectFactory {
    [argumentObjectFactories setValue:objectFactory forKey:typeName];
}

-(NSArray *)getMappedServiceClasses {
    return [serviceObjectFactories allKeys];
}

-(NSArray *)getMappedArgumentClasses {
    return [argumentObjectFactories allKeys];
}

-(id <IServiceObjectFactory>)getServiceObjectFactory:(NSString *)serviceTypeName {
    return [serviceObjectFactories valueForKey:serviceTypeName];
}

-(id <IArgumentObjectFactory>)getArgumentObjectFactory:(NSString *)argumentTypeName {
    return [argumentObjectFactories valueForKey:argumentTypeName];
}

-(void)removeServiceObjectFactoryFor:(NSString *)serviceTypeName {
    [serviceObjectFactories removeObjectForKey:serviceTypeName];
}

-(void)removeArgumentObjectFactoryFor:(NSString *)argumentTypeName {
    [argumentObjectFactories removeObjectForKey:argumentTypeName];
}

@end
