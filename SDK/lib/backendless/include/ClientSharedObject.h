//
//  ClientSharedObject.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
