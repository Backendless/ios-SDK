//
//  ISharedObjectMessage.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
