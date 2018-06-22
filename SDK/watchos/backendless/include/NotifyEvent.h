//
//  NotifyEvent.h
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
#import "IServiceCall.h"
#import "BaseEvent.h"
#import "BinaryStream.h"

@interface NotifyEvent : BaseEvent {
	id <IServiceCall>	call;
	BinaryStream		*data;
	int					invokeId;
	NSDictionary		*connectionParams;
}
@property (nonatomic, assign, readwrite) id <IServiceCall> call;
@property (nonatomic, assign, readwrite) BinaryStream *data;
@property (readwrite) int invokeId;
@property (nonatomic, assign, readwrite) NSDictionary *connectionParams;

-(id)initWithStream:(BinaryStream *)stream;
-(id)initWithCall:(id <IServiceCall>)_call;	

-(BOOL)equals:(id)event;
-(NSString *)toString;
-(NotifyEvent *)duplicate;

@end
