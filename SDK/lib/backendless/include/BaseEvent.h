//
//  BaseEvent.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
