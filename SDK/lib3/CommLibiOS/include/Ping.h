//
//  Ping.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 07.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"


enum ping_event_state
{
	STREAM_BEGIN = 0,
    STREAM_PLAYBUFFER_CLEAR = 1,	// stream play
    STREAM_DRY = 2,					// unknown event
    CLIENT_BUFFER = 3,				// client buffer
    RECORDED_STREAM = 4,			// stream reset
    UNKNOWN_5 = 5,					// unknown event
    PING_CLIENT = 6,				// client ping event
    PONG_SERVER = 7,				// server response event
	UNKNOWN_8 = 8,					// unknown event
    UNDEFINED = -1,					// undefined
};

@interface Ping : BaseEvent {
	int		value2;
	int		value3;
	int		value4;
	short	eventType;

}
@property (readwrite) int value2;
@property (readwrite) int value3;
@property (readwrite) int value4;
@property (readwrite) short	eventType;

-(id)initWithType:(short)_eventType value2:(int)_value2;
-(id)initWithType:(short)_eventType value2:(int)_value2 value3:(int)_value3;
-(id)initWithType:(short)_eventType value2:(int)_value2  value3:(int)_value3 value4:(int)_value4;
@end
