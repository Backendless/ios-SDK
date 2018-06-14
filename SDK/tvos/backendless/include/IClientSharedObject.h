//
//  IClientSharedObject.h
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

#import "IPersistable.h"
#import "IAttributeStore.h"

@protocol IClientSharedObject <IPersistable, IAttributeStore> 

/**
 * Connect the shared object using the passed connection.
 * 
 * @param conn connect to connect to
 */
-(void)connect;

/**
 * Check if the shared object is connected to the server.
 * 
 * @return is connected
 */
-(BOOL)isConnected;

/**
 * Disconnect the shared object.
 */
-(void)disconnect;

/**
 * Send a message to a handler of the shared object.
 * 
 * @param handler
 *            the name of the handler to call
 * @param arguments
 *            a list of objects that should be passed as arguments to the
 *            handler
 */
-(void)sendMessage:(NSString *)handler arguments:(NSArray *)arguments;

/**
 * Deletes all the attributes. 
 * The persistent data object is also removed from a persistent shared object.
 * 
 * @return true if successful; false otherwise
 */
-(BOOL)clear;

/**
 * Detaches a reference from this shared object, this will destroy the
 * reference immediately. This is useful when you don't want to proxy a
 * shared object any longer.
 */
-(void)close;

@end
