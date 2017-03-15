//
//  BaseRTMPProtocolDecoder.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BaseRTMPProtocolDecoder.h"
#import "DEBUG.h"
#import "IDeserializer.h"
#import "Header.h"
#import "Packet.h"
#import "WebORBDeserializer.h"
#import "FlashorbBinaryWriter.h"
#import "FlashorbBinaryReader.h"
#import "RTMPConstants.h"
#import "Datatypes.h"
#import "IRTMPEvent.h"
#import "Invoke.h"
#import "NotifyEvent.h"
#import "Ping.h"
#import "NumberObject.h"
#import "StringType.h"
#import "Call.h"
#import "SharedObjectMessage.h"
#import "AudioData.h"
#import "VideoData.h"
#import "Aggregate.h"
#import "FlexMessage.h"
#import "PendingCall.h"
#import "MetaData.h"


@interface BaseRTMPProtocolDecoder ()
-(id <IRTMPEvent>)decodeMessage;
-(id <IRTMPEvent>)decodeChunkSize;
-(id <IRTMPEvent>)decodeAbort;
-(id <IRTMPEvent>)decodeInvoke;	
-(id <IRTMPEvent>)decodeNotify;	
-(id <IRTMPEvent>)decodeStreamMetadata;
-(id <IRTMPEvent>)decodePing;
-(id <IRTMPEvent>)decodeBytesRead;
-(id <IRTMPEvent>)decodeAudioData;
-(id <IRTMPEvent>)decodeVideoData;
-(id <IRTMPEvent>)decodeFlexSharedObject;
-(id <IRTMPEvent>)decodeSharedObject;
-(id <IRTMPEvent>)decodeServerBW;
-(id <IRTMPEvent>)decodeClientBW;
-(id <IRTMPEvent>)decodeFlexMessage;
-(id <IRTMPEvent>)decodeFlexStreamSend;
-(id <IRTMPEvent>)decodeUnknown;
-(id <IRTMPEvent>)decodeAggregateMessage;
@end

@implementation BaseRTMPProtocolDecoder

-(id)init {
	if( (self=[super init]) ) {
		decoder = nil;
		input = nil;
		event = nil;
	}
	
	return self;
}

-(id)initWithDecoder:(id <IDeserializer>)deserializer {
	if( (self=[super init]) ) {
		[self setDeserializer:deserializer];
		event = nil;
	}
	
	return self;
}

+(id)decoder {
	return [[[BaseRTMPProtocolDecoder alloc] init] autorelease];
}

+(id)decoder:(id <IDeserializer>)deserializer {
	return [[[BaseRTMPProtocolDecoder alloc] initWithDecoder:deserializer] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BaseRTMPProtocolDecoder"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)setDeserializer:(id <IDeserializer>)deserializer {
	if (!deserializer) {
		decoder = nil;
		input = nil;
		return;
	}
	decoder = deserializer;
	input = [decoder getStream];		
}

+(int)chunkStreamID:(FlashorbBinaryReader *)input {
	
	if (![input remaining])
		return -1;
	
    int headerByte = [input readByte];
	int streamID = headerByte & CHUNK_STREAM_MASK;
    
    int chunkStreamId = -1;
    
	switch (streamID) {
		case 0:
			chunkStreamId = ([input remaining] > 1) ? [input readByte] + 64 : -1;
            break;
		case 1:
			chunkStreamId = ([input remaining] > 2) ? [input readInt16] + 64 : -1;
            break;
		default:
			chunkStreamId = streamID;
            break;
	}
    
    //[DebLog log:@"chunkStreamID = %d, chunkType = %d", chunkStreamId, (headerByte&CHUNK_HEADER_MASK)>>6];
    return chunkStreamId;
}

+(Header *)chunkHeader:(FlashorbBinaryReader *)input lastHeader:(Header *)last {
	
	if (![input remaining])
		return nil;
	
	[DebLog logN:@"[input remaining] = %d", [input remaining]];
	
	int chunkHeader = (int)(([input get] & CHUNK_HEADER_MASK) >> 6);
	int chunkStreamID = [BaseRTMPProtocolDecoder chunkStreamID:input];
	if (chunkStreamID < 0)
		return nil;
	
	[DebLog logN:@"BaseRTMPProtocolDecoder->chunkHeader: chunkHeader = %d, chunkStreamID = %d", chunkHeader, chunkStreamID];
	
	Header *header = [Header header];
	header.channelId = chunkStreamID;
	switch (chunkHeader) {
		case HEADER_NEW:
			if ([input remaining] < 11)
				return nil;
			header.timerDelta = 0;
			header.timerBase = [input readUInt24];
			header.size = [input readUInt24];
			header.dataType = [input readByte];
			header.streamId = [input readInt32];
            header.timerExt = (header.timerBase == IS_EXT_TIMESTAMP);
            if (header.timerExt)
                header.timerBase = [input readUInteger];
			break;
		case HEADER_SAME_SOURCE:
			if (!last || [input remaining] < 7)
				return nil;
			header.timerBase = [last getTimer];
			header.timerDelta = [input readUInt24];
			header.size = [input readUInt24];
			header.dataType = [input readByte];
			header.streamId = last.streamId;
            header.timerExt = (header.timerDelta == IS_EXT_TIMESTAMP);
            if (header.timerExt)
                header.timerDelta = [input readUInteger];
			break;
		case HEADER_TIMER_CHANGE:
			if (!last || [input remaining] < 3)
				return nil;
			header.timerBase = [last getTimer];
			header.timerDelta = [input readUInt24];
			header.size = last.size;
			header.dataType = last.dataType;
			header.streamId = last.streamId;
            header.timerExt = (header.timerDelta == IS_EXT_TIMESTAMP);
            if (header.timerExt)
                header.timerDelta = [input readUInteger];
			break;
		case HEADER_CONTINUE:
			if (!last)
				return nil;
			header.timerBase = [last getTimer];
			header.timerDelta = last.timerDelta;
			header.size = last.size;
			header.dataType = last.dataType;
			header.streamId = last.streamId;
            header.timerExt = last.timerExt;
            if (header.timerExt)
                header.timerDelta = [input readUInteger];
			break;
		default:
			return nil;
	}
	
	[DebLog logN:@"BaseRTMPProtocolDecoder->chunkHeader: header = %@", header.toString];
	
	return header;
}

-(BOOL)decodePacket:(Packet *)packet {
	
	if (!packet)
		return NO;
	
	event = packet;
	FlashorbBinaryReader *buf = [[FlashorbBinaryReader alloc] initWithStream:event.data.buffer andSize:event.data.size];
	decoder = [WebORBDeserializer reader:buf];
	input = [decoder getStream];			
	
	event.message = [self decodeMessage]; 
	[buf release];

	return (event.message != nil);
}

#pragma mark -
#pragma mark Private Methods

-(id <IRTMPEvent>)decodeMessage {
	
	if (!decoder || !input || ([input remaining] < event.header.size))
		return nil;
	
	switch (event.header.dataType) {
		case TYPE_CHUNK_SIZE:
			return [self decodeChunkSize];
		case TYPE_ABORT:
			return [self decodeAbort];
		case TYPE_INVOKE:
			return [self decodeInvoke];
        case TYPE_STREAM_METADATA_AMF3:
		case TYPE_NOTIFY:
			return (event.header.streamId == 0) ? [self decodeNotify] : [self decodeStreamMetadata];
		case TYPE_PING:
			return [self decodePing];
		case TYPE_BYTES_READ:
			return [self decodeBytesRead];
		case TYPE_AUDIO_DATA:
			return [self decodeAudioData];
		case TYPE_VIDEO_DATA:
			return [self decodeVideoData];
		case TYPE_FLEX_SHARED_OBJECT:
			return [self decodeFlexSharedObject];
		case TYPE_SHARED_OBJECT:
			return [self decodeSharedObject];
		case TYPE_SERVER_BANDWIDTH:
			return [self decodeServerBW];
		case TYPE_CLIENT_BANDWIDTH:
			return [self decodeClientBW];
		case TYPE_FLEXINVOKE:
			return [self decodeFlexMessage];
		case TYPE_FLEX_STREAM_SEND:
			return [self decodeFlexStreamSend];
        case TYPE_AGGREGATE:
            return [self decodeAggregateMessage];
		default:
			return [self decodeUnknown];
	}
}

-(id <IRTMPEvent>)decodeChunkSize {
	
	return nil;
}

-(id <IRTMPEvent>)decodeAbort {
	
	return nil;
}

-(id <IRTMPEvent>)decodeInvoke {
	
	[DebLog logN:@"START decodeInvoke"];
	
	NSString *action = [decoder deserialize];
	
	[DebLog logN:@"decodeInvoke - ACTION: '%@'", action];
	
	if (!action)
		return nil;
	
	Invoke *result = [[[Invoke alloc] init] autorelease];
	Header *header = event.header;
	
	if (header.streamId == 0) {
		NSNumber *num = [decoder deserialize];
		result.invokeId = [num intValue];
		
		[DebLog logN:@" >>>>>>>>>> invokeId = %d", result.invokeId];
	}
	
	NSMutableArray *params = [NSMutableArray array];
	
	if ([input remaining]) {
		
		id obj = [decoder deserialize];
		
		[DebLog logN:@">>>>> (0) obj = '%@'", obj];
		
        if (obj) {
			result.connectionParams = obj;
		}
		
        while ([input remaining] && (obj = [decoder deserialize])) {
            
            [DebLog logN:@">>>>> (1) obj = '%@'", obj];
            
			[params addObject:obj];
		}
	}
	
	//result.call = [[Call alloc] initWithName:nil andMethod:action andArguments:params]; // *** LEAKS
	result.call = [[[Call alloc] initWithName:nil andMethod:action andArguments:params] autorelease];
	
	[DebLog logN:@"FINISH decodeInvoke -> arguments = %d", [params count]];
	
	return result;
}

-(id <IRTMPEvent>)decodeNotify {
	
	NSString *action = [decoder deserialize];
	
	[DebLog log:@"decodeNotify - ACTION: '%@'", action];
	
	return nil;
}

-(id <IRTMPEvent>)decodeStreamMetadata {
    
	/*/
    [DebLog logY:@"BaseRTMPProtocolDecoder -> decodeStreamMetadata - DATA:\n"];
    BinaryStream *data = [decoder getStream];
    [data print:YES];
    /*/
	
	NSString *action = [decoder deserialize];
	
	[DebLog log:@"BaseRTMPProtocolDecoder -> decodeStreamMetadata - ACTION: '%@'", action];
	
	if (!action)
		return nil;
    
    if ([action isEqualToString:SET_DATA_EVENT]) {
        
        NSString *ev = [decoder deserialize];
        
        [DebLog log:@"BaseRTMPProtocolDecoder -> decodeStreamMetadata - EVENT: '%@'", ev];
        
        id obj = [decoder deserialize];
        MetaData *metadata = [[MetaData alloc] initWithMetadata:obj];
        metadata.dataSet = SET_DATA_EVENT;
        metadata.eventName = ev;
        return [metadata autorelease];
    }
    
    if ([action isEqualToString:ON_METADATA]) {
        
        id obj = [decoder deserialize];
        return [[[MetaData alloc] initWithMetadata:obj] autorelease];
    }
    
    return nil;
}

-(id <IRTMPEvent>)decodePing {
	
	[DebLog logN:@"START decodePing"];
    
    if ([input remaining] < 6)
        return nil;

    Ping *ping = [[[Ping alloc] initWithType:(EventType)[input readUnsignedShort]] autorelease];
    ping.value2 = [input readInteger];    
    if ([input remaining]) {
        ping.value3 = [input readInteger];
        if ([input remaining])
            ping.value4 = [input readInteger];
    }
	
    [DebLog logN:@"FINISH decodePing"];
		
	return ping;
}

-(id <IRTMPEvent>)decodeBytesRead {
	
	return nil;
}

-(id <IRTMPEvent>)decodeAudioData {
	//return [[AudioData alloc] initWithBinaryStream:[[BinaryStream alloc] initWithStream:input.buffer andSize:input.size]]; // *** LEAKS
	return [[[AudioData alloc] initWithBinaryStream:[BinaryStream streamWithStream:input.buffer andSize:input.size]] autorelease];
}

-(id <IRTMPEvent>)decodeVideoData {
	//return [[VideoData alloc] initWithBinaryStream:[[BinaryStream alloc] initWithStream:input.buffer andSize:input.size]]; // *** LEAKS
	return [[[VideoData alloc] initWithBinaryStream:[BinaryStream streamWithStream:input.buffer andSize:input.size]] autorelease];
}

-(id <IRTMPEvent>)decodeFlexSharedObject {
    [input next]; // unknown byte
	return [self decodeSharedObject];
}

#define _ON_DECODER_LOG_ NO

-(id <IRTMPEvent>)decodeSharedObject {
	
    [DebLog log:_ON_DECODER_LOG_ text:@"START decodeSharedObject"];
    
    NSString *name = [input readString];
    int version = [input readInteger];
    BOOL persistent = ([input readInteger] == 2);
    [input readInteger]; // skip unknown bytes
	
    [DebLog log:_ON_DECODER_LOG_ text:@"(1) decodeSharedObject: name = %@, version = %d, persistent = %d", name, version, persistent];
    
    SharedObjectMessage *so = [[[SharedObjectMessage alloc] initWithName:name version:version persistent:persistent] autorelease];
    WebORBDeserializer *deserializer3 = [WebORBDeserializer reader:input andVersion:3];
    //
    while ([input remaining]) {
        
        SharedObjectEventType type = (SharedObjectEventType)[input readChar];
        NSString *key = nil;
        id value = nil;
        unsigned int length = [input readUInteger];
        
        [DebLog log:_ON_DECODER_LOG_ text:@"(2) decodeSharedObject: type = %d, length = %d", (int)type, length];
#if 1
        if (type > CLIENT_INITIAL_DATA) {
            [DebLog logY:@"(!!! ERROR !!!) decodeSharedObject: WRONG type = %d", (int)type];
            return so;
        }
#endif
#if 1
        if (length > [input remaining]) {
            [DebLog logY:@"(!!! ERROR !!!) decodeSharedObject: WRONG length = %d > %d", length, [input remaining]];
            return so;
        }
#endif
        
        switch (type) {
            case CLIENT_CLEAR_DATA:
            case CLIENT_INITIAL_DATA: {
                
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_CLEAR_DATA || CLIENT_INITIAL_DATA) decodeSharedObject"];
                break;
            }
            case CLIENT_STATUS: {
                // Status code
                key = [input readString];
                // Status level
                value = [input readString];
                
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_STATUS) decodeSharedObject: key = %@, start = %@", key, value];
                break;
            }
            case CLIENT_UPDATE_DATA: {
                //
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_UPDATE_DATA) decodeSharedObject"];
                value = [NSMutableDictionary dictionary];
                
                while ([input remaining]) {
                    
                    BOOL normal = YES;
                    int start = input.position;
                    
                    while (input.position - start < length) {
                        NSString *tmp = [input readString];
                        id obj = [decoder deserialize];
                        if (!tmp || !obj) {
                            normal = NO;
                            break;
                        }
                        [(NSMutableDictionary *)value setValue:obj forKey:tmp];
                    }
                    
                    if (!normal || ((SharedObjectEventType)[input get] != CLIENT_UPDATE_DATA))
                        break;
                    
                    [input readChar];
                    length = [input readInteger];
                }
                
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_UPDATE_DATA) decodeSharedObject -> value.count = %d", [(NSMutableDictionary *)value count]];
                break;
            }
            //
            case CLIENT_SEND_MESSAGE: {
                //
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_SEND_MESSAGE) decodeSharedObject: length = %d", length];
                
                if (!length)
                    break;
                
                int start = input.position;
                key = [decoder deserialize];
                
                [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_SEND_MESSAGE (1)) decodeSharedObject: key = %@, start = %d, position = %d, length = %d", key, start, input.position, length];
                
                // read arguments
                value = [NSMutableArray array];
                while (input.position - start < length) {
                    
                    [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_SEND_MESSAGE (2)) decodeSharedObject: decoder type = %d, position = %d", [input get], input.position];
                    
                    id <IDeserializer> des = ([input get] == V3_DATATYPE) ? deserializer3 : decoder;
                    id obj = [des deserialize];
                    [(NSMutableArray *)value addObject:(obj)?obj:[NSNull null]];
                    
                    [DebLog log:_ON_DECODER_LOG_ text:@"(CLIENT_SEND_MESSAGE (3)) decodeSharedObject: obj = %@, position = %d", obj, input.position];
                }
                break;
            }
            //    
            default: {
                
               // the "send" event seems to encode the handler name as complete AMF string including the string type byte                
                int start = input.position;
                key = [input readString];
                
                [DebLog log:_ON_DECODER_LOG_ text:@"(default (1)) decodeSharedObject: key = %@, start = %d, position = %d, length = %d", key, start, input.position, length];
                
                // read parameters
                value = [NSMutableArray array];
                while (input.position - start < length) {
                    
                    int pos = input.position;
                    
                    [DebLog log:_ON_DECODER_LOG_ text:@"(default (2)) decodeSharedObject: decoder type = %d, position = %d", [input get], input.position];
                    
                    id <IDeserializer> des = ([input get] == V3_DATATYPE) ? deserializer3 : decoder;
                    id obj = [des deserialize];
                    [(NSMutableArray *)value addObject:(obj)?obj:[NSNull null]];
                   
                    [DebLog log:_ON_DECODER_LOG_ text:@"(default (3)) decodeSharedObject: obj = %@, position = %d", obj, input.position];
#if 1
                    if (input.position == pos) {
                        [DebLog logY:@"(!!! ERROR !!!) decodeSharedObject: !!! default CYCLING"];
                        return so;
                    }
#endif
                }
                break;
            }
        }
        
        [so addEvent:type withKey:key andValue:value];
    }
 	
    [DebLog log:_ON_DECODER_LOG_ text:@"FINISH decodeSharedObject: %@", [so getEvents]];
	
	return so;
}

-(id <IRTMPEvent>)decodeServerBW {
	
	return nil;
}

-(id <IRTMPEvent>)decodeClientBW {
	
	return nil;
}

-(id <IRTMPEvent>)decodeFlexMessage {
	
	[DebLog logN:@"START decodeFlexMessage"];
    
    [input next]; // skip the first byte
	
	FlexMessage *result = [[[FlexMessage alloc] init] autorelease];
    NSString *serviceName = nil;
    NSString *serviceMethod = nil;	
	NSString *action = [decoder deserialize];
    if (action) {
        NSArray *arr = [action componentsSeparatedByString:@"."];
        int count = arr.count;
        if (count > 1) {
            serviceName  = [arr objectAtIndex:0];
            for (int i = 1; i < count-1; i++)
                serviceName = [NSString stringWithFormat:@"%@.%@", serviceName, [arr objectAtIndex:i]];
        }
        serviceMethod = [arr objectAtIndex:count-1];
    }
		
    id num = [decoder deserialize];
    result.invokeId = ([num isKindOfClass:[NSNumber class]]) ? [(NSNumber *)num intValue] : 0;
	
	[DebLog logN:@">>>>> ACTION: '%@', serviceName = '%@', serviceMethod = '%@', invokeId = %d", action, serviceName, serviceMethod, result.invokeId];
	
	NSMutableArray *params = [NSMutableArray array];
	
	if ([input remaining]) {
        
        WebORBDeserializer *deserializer3 = [WebORBDeserializer reader:input andVersion:3];
		
		id obj = [decoder deserialize];
		
		[DebLog logN:@">>>>> connectionParams = '%@'", obj];
		
        if (obj) {
			result.connectionParams = obj;
		}
		
        while ([input remaining]) {
            id <IDeserializer> des = ([input get] == V3_DATATYPE) ? deserializer3 : decoder;
            id obj = [des deserialize];
 			[params addObject:(obj)?obj:[NSNull null]];
           
            [DebLog logN:@">>>>> obj = %@, position = %d", obj, input.position];
		}
	}
	
	//result.call = [[PendingCall alloc] initWithName:serviceName andMethod:serviceMethod andArguments:params]; // *** LEAKS
	result.call = [[[PendingCall alloc] initWithName:serviceName andMethod:serviceMethod andArguments:params] autorelease];
	
	[DebLog logN:@"FINISH decodeFlexMessage"];
	
	return result;
}

-(id <IRTMPEvent>)decodeFlexStreamSend {
	
	return nil;
}

-(id <IRTMPEvent>)decodeUnknown {
	
	return nil;
}

-(id <IRTMPEvent>)decodeAggregateMessage {
    //return [[Aggregate alloc] initWithStream:event.data.buffer andSize:event.data.size]; // *** LEAKS
    return [[[Aggregate alloc] initWithStream:event.data.buffer andSize:event.data.size] autorelease];
}

@end
