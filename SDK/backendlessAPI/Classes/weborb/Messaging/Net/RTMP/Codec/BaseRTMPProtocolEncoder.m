//
//  BaseRTMPProtocolEncoder.m
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

#import "BaseRTMPProtocolEncoder.h"
#import "DEBUG.h"
#import "RTMPConstants.h"
#import "Call.h"
#import "PendingCall.h"
#import "Invoke.h"
#import "NotifyEvent.h"
#import "Ping.h"
#import "SharedObjectMessage.h"
#import "AudioData.h"
#import "VideoData.h"
#import "FlexMessage.h"
#import "V3Message.h"
#import "MetaData.h"

@interface BaseRTMPProtocolEncoder ()
-(void)encodeChunkSize;
-(void)encodeAbort;
-(void)encodeInvoke;	
-(void)encodeNotify;	
-(void)encodeStreamMetadata;
-(void)encodePing;
-(void)encodeBytesRead;
-(void)encodeAudioData;
-(void)encodeVideoData;
-(void)encodeFlexSharedObject;
-(void)encodeSharedObject;
-(void)encodeServerBW;
-(void)encodeClientBW;
-(void)encodeFlexMessage;
-(void)encodeFlexStreamSend;
-(void)encodeUnknown;
@end


@implementation BaseRTMPProtocolEncoder

-(id)init {
	if ( (self=[super init]) ) {
		serializer = [WebORBSerializer writer];
		event = nil;
	}	
	return self;
}

+(id)coder {
	return [[[BaseRTMPProtocolEncoder alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BaseRTMPProtocolEncoder"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)setSerializer:(WebORBSerializer *)coder {
	serializer = coder;
}

-(BinaryStream *)encodeMessage:(id <IRTMPEvent>)message {
	
	if (!serializer || !message)
		return nil;
	
	event = message;
	[serializer.buffer begin];
	
	switch ([message getDataType]) {
		case TYPE_CHUNK_SIZE:
			[self encodeChunkSize];
			break;
		case TYPE_ABORT:
			[self encodeAbort];
			break;
		case TYPE_INVOKE:
			[self encodeInvoke];
			break;
		case TYPE_NOTIFY: {
			NotifyEvent *notify = (NotifyEvent *)event;
			if (notify.call)					
				[self encodeNotify];
			else  
				[self encodeStreamMetadata];
			break;
		}
		case TYPE_PING:
			[self encodePing];
			break;
		case TYPE_BYTES_READ:
			[self encodeBytesRead];
			break;
		case TYPE_AUDIO_DATA:
			[self encodeAudioData];
			break;
		case TYPE_VIDEO_DATA:
			[self encodeVideoData];
			break;
		case TYPE_FLEX_SHARED_OBJECT:
			[self encodeFlexSharedObject];
			break;
		case TYPE_SHARED_OBJECT:
			[self encodeSharedObject];
			break;
		case TYPE_SERVER_BANDWIDTH:
			[self encodeServerBW];
			break;
		case TYPE_CLIENT_BANDWIDTH:
			[self encodeClientBW];
			break;
		case TYPE_FLEXINVOKE:
			[self encodeFlexMessage];
			break;
		case TYPE_FLEX_STREAM_SEND:
			[self encodeFlexStreamSend];
			break;
		default:
			[self encodeUnknown];
			break;
	}
	
	return serializer.buffer;
}

#pragma mark -
#pragma mark Private Methods

-(void)encodeChunkSize {
}

-(void)encodeAbort {
}

-(void)encodeInvoke {
	
	Invoke *invoke = (Invoke *)event;
	Call* call = invoke.call;
	BOOL isPending = (call.status == STATUS_PENDING);
	
	if (isPending) {
		NSString *action = (call.serviceName) ? 
						[NSString stringWithFormat:	@"%@.%@", call.serviceName, call.serviceMethodName] : 
						[NSString stringWithString:call.serviceMethodName];
		[serializer serialize:action];
	}
	else {
		NSString *response = ([call isSuccess]) ? @"_result" : @"_error";
		[serializer serialize:[NSString stringWithString:response]];
	}

    [serializer serialize:[NSNumber numberWithDouble:invoke.invokeId]];
	[serializer serialize:invoke.connectionParams];
	
	if (isPending) {
		NSArray *args = call.arguments;
        
        [DebLog logN:@"encodeInvoke -> call.arguments:\n %@", args];
        
		if (args)
			for (id element in args) {
				[serializer serialize:element];
            }
	}
    	
	if (invoke.data) {
		WebORBSerializer *writer = (WebORBSerializer *)serializer;
		[writer.buffer write:invoke.data.buffer length:invoke.data.size];
	}
}

-(void)encodeNotify {
	
	NotifyEvent *notify = (NotifyEvent *)event;
	Call* call = notify.call;
	BOOL isPending = (call.status == STATUS_PENDING);
	
	if (isPending) {
		NSString *action = (call.serviceName) ?
        [NSString stringWithFormat:	@"%@.%@", call.serviceName, call.serviceMethodName] :
        [NSString stringWithString:call.serviceMethodName];
		[serializer serialize:action];
	}
	else {
		NSString *response = ([call isSuccess]) ? @"_result" : @"_error";
		[serializer serialize:[NSString stringWithString:response]];
	}
    
    [serializer serialize:[NSNumber numberWithDouble:notify.invokeId]];
	[serializer serialize:notify.connectionParams];
	
	if (isPending) {
		NSArray *args = call.arguments;
        
        [DebLog logN:@"encodeNotify -> call.arguments:\n %@", args];
        
		if (args)
			for (id element in args) {
				[serializer serialize:element];
            }
	}
    
	if (notify.data) {
		WebORBSerializer *writer = (WebORBSerializer *)serializer;
		[writer.buffer write:notify.data.buffer length:notify.data.size];
	}
}

-(void)encodeStreamMetadata {
    
    MetaData *metadata = (MetaData *)event;
    
    [DebLog logN:@"encodeStreamMetadata -> metadata: %@", metadata];
    
    [serializer serialize:metadata.dataSet];
    [serializer serialize:metadata.eventName];
    [serializer serialize:metadata.metadata];
}

-(void)encodePing {
    
    Ping *ping = (Ping *)event;
    FlashorbBinaryWriter *outBuf = serializer.buffer;
    // event type
    [outBuf writeInt16:(short)ping.eventType];
    [outBuf writeInt:ping.value2];
    if (ping.value3 != UNDEFINED) {
        [outBuf writeInt:ping.value3];
        if (ping.value4 != UNDEFINED)
            [outBuf writeInt:ping.value4];
    }
}

-(void)encodeBytesRead {
}

-(void)encodeAudioData {
    BinaryStream *data = [(AudioData *)event getData];
    if (data) [serializer.buffer write:data.buffer length:data.size];
}

-(void)encodeVideoData {
    BinaryStream *data = [(VideoData *)event getData];
    if (data) [serializer.buffer write:data.buffer length:data.size];
}

-(void)encodeFlexSharedObject {
    [serializer.buffer writeChar:0];
    [self encodeSharedObject];
}

-(void)encodeSharedObject {
    
    SharedObjectMessage *so = (SharedObjectMessage *)event;
    FlashorbBinaryWriter *outBuf = serializer.buffer;
    // SO name
    [outBuf writeString:[so getName]];
    // SO version
    [outBuf writeInt:[so getVersion]];
    // persistent == 2 for persistent shared oblect
    [outBuf writeInt:([so isPersistent]?2:0)];
    // unknown field
    [outBuf writeInt:0];
    // SO events
    NSArray *events = [so getEvents];
    
    [DebLog logN:@"encodeSharedObject events = %d", events.count];
    
    for (id <ISharedObjectEvent> evt in events) {
        
        SharedObjectEventType type = (SharedObjectEventType)[evt getType];
        switch (type) {
            //
            case SERVER_CONNECT:
            case SERVER_DISCONNECT:
            case CLIENT_INITIAL_DATA:
            case CLIENT_CLEAR_DATA: {
                [outBuf writeChar:(char)type];
                [outBuf writeInt:0];
                break;
            }
                //
            case SERVER_DELETE_ATTRIBUTE:
            case CLIENT_DELETE_DATA:
            case CLIENT_UPDATE_ATTRIBUTE: {
                [outBuf writeChar:(char)type];
                NSString *key = [evt getKey];
                [outBuf writeInt:(int)key.length+2];
                [outBuf writeString:key];
                break;
            }
                //
            case SERVER_SET_ATTRIBUTE:
            case CLIENT_UPDATE_DATA: {
                NSString *key = [evt getKey];
                if (!key) {
                    // Update multiple attributes in one request
                    NSDictionary *initialData = (NSDictionary *)[evt getValue];
                    NSArray *keys = [initialData allKeys];
                    
                    [DebLog logN:@"encodeSharedObject (CLIENT_UPDATE_DATA) attributes = %d", keys.count];
                    
                    for (NSString *name in keys) {
                        [outBuf writeChar:(char)type];
                        int mark = outBuf.position;
                        [outBuf writeInt:0]; // final data length will be here
                        [outBuf writeString:name];
                        [serializer serialize:[initialData valueForKey:name]];
                        // fix data length    
                        int last = outBuf.position;
                        int len = last - mark - 4;
                        [outBuf seek:mark];
                        [outBuf writeInt:len];
                        [outBuf seek:last];
                  }
                }
                else {
                    [outBuf writeChar:(char)type];
                    int mark = outBuf.position;
                    [outBuf writeInt:0]; // final data length will be here
                    [outBuf writeString:key];
                    [serializer serialize:[evt getValue]];                    
                    // fix data length    
                    int last = outBuf.position;
                    int len = last - mark - 4;
                    [outBuf seek:mark];
                    [outBuf writeInt:len];
                    [outBuf seek:last];
                }
                break;
            }
            //
            //case SERVER_SEND_MESSAGE:
            case CLIENT_SEND_MESSAGE: {
                // Send method name and value
                [outBuf writeChar:(char)type];
                int mark = outBuf.position;
                [outBuf writeInt:0]; // final data length will be here
                // Serialize name of the handler to call...
                [serializer serialize:[evt getKey]];                    
                // ...and the arguments
                NSArray *arguments = (NSArray *)[evt getValue];
                for (id arg in arguments) 
                    [serializer serialize:arg];                                       
                // fix data length    
                int last = outBuf.position;
                int len = last - mark - 4;
                [outBuf seek:mark];
                [outBuf writeInt:len];
                [outBuf seek:last];
                break;
            }
            //    
            case CLIENT_STATUS: {
                [outBuf writeChar:(char)type];
                NSString *status = [evt getKey];
                NSString *message = (NSString *)[evt getValue];
                [outBuf writeInt:((int)message.length + (int)status.length+4)];
                [outBuf writeString:message];
                [outBuf writeString:status];
                break;
            }
                //    
           default: {
               // XXX: come back here, need to make this work in server or
               // client mode talk to joachim about this part.
               [outBuf writeChar:(char)type];
               int mark = outBuf.position;
               [outBuf writeInt:0]; // final data length will be here
               NSString *key = [evt getKey];
               [outBuf writeString:key];
               [serializer serialize:[evt getValue]];                    
               // fix data length    
               int last = outBuf.position;
               int len = last - mark - 4;
               [outBuf seek:mark];
               [outBuf writeInt:len];               
               [outBuf seek:last];
               break;
            }
        }
    }
}

-(void)encodeServerBW {
}

-(void)encodeClientBW {
}

-(void)encodeFlexMessage {
    
    FlexMessage *msg = (FlexMessage *)event;
    FlashorbBinaryWriter *outBuf = serializer.buffer;
    
    NSArray *arr = (msg.obj) ? (NSArray *)msg.obj : (NSArray *)[msg.call getArguments];
    V3Message *message = (V3Message *)[arr objectAtIndex:0];
    
    [outBuf writeChar:(char)0];
    [serializer serialize:msg.command];
    [serializer serialize:(msg.invokeId)?[NSNumber numberWithDouble:msg.invokeId]:nil];
	[serializer serialize:msg.connectionParams];
    [serializer serialize:message version:msg.version];
}

-(void)encodeFlexStreamSend {
}

-(void)encodeUnknown {
}

@end
