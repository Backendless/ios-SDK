//
//  BaseEvent.h
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
#import "EventType.h"
#import "IRTMPEvent.h"
#import "IEventListener.h"
#import "Header.h"

@interface BaseEvent : NSObject <IRTMPEvent> {
	EventType		type;
	id				obj;
	id <IEventListener>	source;
	int				timestamp;
	Header			*header;
	uint			sourceType;
}
@property EventType	type;
@property (nonatomic, assign) id obj;
@property (nonatomic, assign) id <IEventListener> source;
@property int timestamp;
@property (nonatomic, assign) Header *header;
@property uint sourceType;

-(id)initWithType:(EventType)eventType;
-(id)initWithType:(EventType)eventType andSource:(id <IEventListener>)eventSource;

@end
