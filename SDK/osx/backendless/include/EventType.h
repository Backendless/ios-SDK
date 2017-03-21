//
//  EventType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

typedef enum enent_type EventType;

enum enent_type
{
	SYSTEM,
	STATUS,
	SERVICE_CALL,
	SHARED_OBJECT,
	STREAM_CONTROL,
	STREAM_DATA,
	CLIENT,
	SERVER,
};

