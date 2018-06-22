//
//  ObjectFactories.h
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
