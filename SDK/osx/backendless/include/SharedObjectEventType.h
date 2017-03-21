//
//  SharedObjectEventType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

typedef enum shared_object_event_type SharedObjectEventType;

enum shared_object_event_type
{
	SERVER_CONNECT = 0x01, 
	SERVER_DISCONNECT = 0x02, 
	SERVER_SET_ATTRIBUTE = 0x03, 
	CLIENT_UPDATE_DATA = 0x04, 
	CLIENT_UPDATE_ATTRIBUTE = 0x05, 
	SERVER_SEND_MESSAGE = 0x06, 
	CLIENT_SEND_MESSAGE = 0x06,
	CLIENT_STATUS = 0x07,        
	CLIENT_CLEAR_DATA = 0x08, 
	CLIENT_DELETE_DATA = 0x09, 
	SERVER_DELETE_ATTRIBUTE = 0x0A,        
	CLIENT_INITIAL_DATA = 0x0B, 
	CLIENT_DELETE_ATTRIBUTE = 0x0A,        
	UNKNOWN = 0x00,
};
