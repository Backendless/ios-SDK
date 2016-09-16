//
//  ObjectFactories.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/21/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"
#import "IServiceObjectFactory.h"
#import "IArgumentObjectFactory.h"

@interface ObjectFactories : NSObject {
    NSMutableDictionary *serviceObjectFactories;
    NSMutableDictionary *argumentObjectFactories;
}

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(ObjectFactories *)sharedInstance;
//
-(id)createServiceObjectByName:(NSString *)className;
-(id)createServiceObjectByType:(Class)type;
-(id)createArgumentObjectByName:(NSString *)className argument:(id <IAdaptingType>)argument;
-(id)createArgumentObjectByType:(Class)type argument:(id <IAdaptingType>)argument;
-(void)addServiceObjectFactory:(NSString *)typeName factory:(id <IServiceObjectFactory>)objectFactory;
-(void)addArgumentObjectFactory:(NSString *)typeName factory:(id <IArgumentObjectFactory>)objectFactory;
-(NSArray *)getMappedServiceClasses;
-(NSArray *)getMappedArgumentClasses;
-(id <IServiceObjectFactory>)getServiceObjectFactory:(NSString *)serviceTypeName;
-(id <IArgumentObjectFactory>)getArgumentObjectFactory:(NSString *)argumentTypeName;
-(void)removeServiceObjectFactoryFor:(NSString *)serviceTypeName;
-(void)removeArgumentObjectFactoryFor:(NSString *)argumentTypeName;
@end
