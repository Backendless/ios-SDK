//
//  ClientSharedObject.h
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
#import "IClientSharedObjectDelegate.h"
#import "WeborbSharedObject.h"
#import "IClientSharedObject.h"
#import "IEventDispatcher.h"
#import "ISharedObjectListener.h"


@interface ClientSharedObject : WeborbSharedObject <IClientSharedObject, IEventDispatcher> {
	// delegate
	id <IClientSharedObjectDelegate>	delegate;
    // owner
    id <ISharedObjectListener>          owner;
	
    BOOL    initialSyncReceived;
}
@property (nonatomic, assign) id <IClientSharedObjectDelegate> delegate;
@property (nonatomic, assign) id <ISharedObjectListener> owner;

-(id)initWithName:(NSString *)_name persistent:(BOOL)_persistent;
@end
