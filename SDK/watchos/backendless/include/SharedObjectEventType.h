//
//  SharedObjectEventType.h
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

typedef enum shared_object_event_type SharedObjectEventType;

enum shared_object_event_type {
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
