//
//  SharedObjectMessage.h
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
#import "BaseEvent.h"
#import "ISharedObjectMessage.h"

@interface SharedObjectMessage : BaseEvent <ISharedObjectMessage> {
	NSString		*name;
	NSMutableArray	*events;
	int				version;
	BOOL			persistent;
}

-(id)initWithName:(NSString *)_name version:(int)_version persistent:(BOOL)_persistent;	
-(id)initWithSource:(id <IEventListener>)_source name:(NSString *)_name version:(int)_version persistent:(BOOL)_persistent;	

-(void)setVersion:(int)_version;
-(void)setName:(NSString *)_name;
-(void)setIsPersistent:(BOOL)_persistent;
-(void)addEvents:(NSArray *)listEvents;
-(EventType)getType;
-(id)getObject;
@end
