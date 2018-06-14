//
//  ISharedObjectMessage.h
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

#import "IRTMPEvent.h"
#import "SharedObjectEventType.h"
#import "ISharedObjectEvent.h"

@protocol ISharedObjectMessage <IRTMPEvent>
/**
 * Returns the name of the shared object this message belongs to.
 *
 * @return name of the shared object
 */
-(NSString *)getName;

/**
 * Returns the version to modify.
 *
 * @return version to modify
 */
-(int)getVersion;

/**
 * Does the message affect a persistent shared object?
 *
 * @return true if a persistent shared object should be updated otherwise false
 */
-(BOOL)isPersistent;

/**
 * Returns a set of ISharedObjectEvent objects containing informations what to change.
 *
 * @return set of ISharedObjectEvents
 */
-(NSArray *)getEvents;

-(void)addEvent:(SharedObjectEventType)type withKey:(NSString *)key andValue:(id)value;
-(void)addEvent:(id <ISharedObjectEvent>)evt;
-(void)clear;
-(BOOL)isEmpty;

@end
