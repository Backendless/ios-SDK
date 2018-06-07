//
//  Paket.m
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

#import "Packet.h"
#import "DEBUG.h"
#import "FlashorbBinaryReader.h"
#import "FlashorbBinaryWriter.h"
#import "BaseRTMPProtocolDecoder.h"
#import "Header.h"
#import "IRTMPEvent.h"


@implementation Packet
@synthesize header, data, message, isHeader, isRetained;

-(id)init {
	if ( (self=[super init]) ) {
		header = [Header header];
		data = [[[FlashorbBinaryWriter alloc] initWithAllocation:1] autorelease];
		message = nil;
		isHeader = YES;
        isRetained = NO;
	}
	return self;
}

-(id)initRetained {
	if ( (self=[super init]) ) {
		header = [[Header alloc] init];
		data = [[FlashorbBinaryWriter alloc] initWithAllocation:1];
		message = nil;
		isHeader = YES;
        isRetained = YES;
	}
	return self;
}

-(id)initWithHeader:(Header *)head andData:(FlashorbBinaryWriter *)stream {
	if ( (self=[super init]) ) {
		header = head;
		data = stream;
		message = nil;
		isHeader = YES;
        isRetained = NO;
	}
	return self;
}

-(id)initWithHeader:(Header *)head andEvent:(id <IRTMPEvent>)event {
	if ( (self=[super init]) ) {
		header = head;
		data = [[[FlashorbBinaryWriter alloc] initWithAllocation:1] autorelease];
		message = event;
		isHeader = YES;
        isRetained = NO;
	}
	return self;
}

-(id)initWithData:(char *)buffer ofSize:(size_t)size {
	if ( (self=[super init]) ) {
		FlashorbBinaryReader *chunk = [[FlashorbBinaryReader alloc] initWithStream:buffer andSize:size];		
		header = [BaseRTMPProtocolDecoder chunkHeader:chunk lastHeader:[Header header]];
		data = [[[FlashorbBinaryWriter alloc] initWithAllocation:size] autorelease];
		memmove(data.buffer, buffer, size);
		message = nil;
		isHeader = YES;
        isRetained = NO;
		[chunk release];
	}
	return self;
}

-(id)initWithRetainedData:(char *)buffer ofSize:(size_t)size {
	if ( (self=[super init]) ) {
		FlashorbBinaryReader *chunk = [[FlashorbBinaryReader alloc] initWithStream:buffer andSize:size];	
        // retained header
		header = [[Header alloc] initWithHeader:[BaseRTMPProtocolDecoder chunkHeader:chunk lastHeader:[Header header]]]; 
		// retained data
        data = [[FlashorbBinaryWriter alloc] initWithAllocation:size];
		memmove(data.buffer, buffer, size);
		message = nil;
		isHeader = YES;
        isRetained = YES;
		[chunk release];
	}
	return self;
}

+(id)packet {
	return [[[Packet alloc] init] autorelease];
	//return [[[Packet alloc] initRetained] autorelease];
}

+(id)packetWithHeader:(Header *)head andData:(FlashorbBinaryWriter *)stream {
	return [[[Packet alloc] initWithHeader:head  andData:stream] autorelease];
}

+(id)packetWithHeader:(Header *)head andEvent:(id <IRTMPEvent>)event {
	return [[[Packet alloc] initWithHeader:head andEvent:event] autorelease];
}

+(id)packetWithData:(char *)buffer ofSize:(size_t)size {
	return [[[Packet alloc] initWithData:buffer ofSize:size] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Packet"];
    
    if (isRetained) {
        [header release];
        [data release];
    }
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)addBuffer:(char *)buffer ofSize:(size_t)size {
	FlashorbBinaryReader *chunk = [[FlashorbBinaryReader alloc] initWithStream:buffer andSize:size];
	header = [BaseRTMPProtocolDecoder chunkHeader:chunk lastHeader:header];
	[data write:&chunk.buffer[chunk.position] length:[chunk remaining]];
	[chunk release];
}

+(NSString *)keyByChannelId:(int)channelId {
	return [NSString stringWithFormat:@"%d", channelId];
}

-(NSString *)keyByChannelId {
	return [Packet keyByChannelId:header.channelId];
}

-(int)headerSize {
	int size = 1;
	char leader = data.buffer[0];
	int n = leader & CHUNK_STREAM_MASK;
	if (n < 2) size += (n+1);
	switch ((leader & CHUNK_HEADER_MASK) >> 6) {
		case HEADER_NEW:
			size += 11;
            break;
		case HEADER_SAME_SOURCE:
			size += 7;
            break;
		case HEADER_TIMER_CHANGE:
			size += 3;
            break;
		case HEADER_CONTINUE:
			return (header.timerExt) ? size+4 : size;
        default:
            return 0;
	}
    
    // size + 4 for extended timestamp (if normal timestamp == 0xFFFFFF)
    if (((unsigned char)data.buffer[1] & (unsigned char)data.buffer[2] & (unsigned char)data.buffer[3]) == 0xFF)
        size += 4;
    
    return size;
}

-(int)packetSize {
	return header.size + [self headerSize];
}

-(int)pendingSize {
    int headerSize = header.size;
    int dataSize = (int)data.size;
	return headerSize - dataSize;
}

-(void)constructHeader {
	[self constructHeader:HEADER_NEW];	
}

-(void)constructHeader:(RTMPHeaderType)type {
	//[data seek:0];
	int leader = (int)type * 0x40; 
	if (header.channelId < 0x40) {
		leader += header.channelId;
		[data writeByte:leader];
	}
	else if (header.channelId < 0x140) {
		[data writeByte:leader];
		[data writeByte:(header.channelId - 0x40)];
	}
	else {
		[data writeByte:leader];
		[data writeInt16:(short)(header.channelId - 0x40)];
	}
	switch (type) {
		case HEADER_NEW:
			[data writeUInt24:header.timerBase];
			[data writeUInt24:header.size];
			[data writeByte:header.dataType];
			[data writeInt32:header.streamId];
			break;
		case HEADER_SAME_SOURCE:
			[data writeUInt24:header.timerDelta];
			[data writeUInt24:header.size];
			[data writeByte:header.dataType];
			break;
		case HEADER_TIMER_CHANGE: 
			[data writeUInt24:header.timerDelta];
            break;
		case HEADER_CONTINUE: 
            break;
	}	
	
	[DebLog logN:@"Packet->constructHeader: type = %d, size = %lu, \nHEADER: %@", type, data.size, [header toString]];
}

-(void)setMessageLength {
	if (((data.buffer[0] & CHUNK_HEADER_MASK) >> 6) > HEADER_SAME_SOURCE)
		return;
	
	[data seek:4];
	unsigned int size = (int)data.size - [self headerSize];
	[data writeUInt24:size];
	
	if ([DebLog getIsActive]) {
        printf("--- Packet body size = %d\n", size);	
        [data print:NO];	
    }
}

-(void)clearHeaderFromData {
	
	if (!isHeader)
		return;
    
    [data print:NO]; // Output CHUNK DUMP
	
	[data seek:[self headerSize]];
	[data shift];
	
	isHeader = NO;
}

-(id)contentRetained {
    
    if (!isRetained) {
        [header retain];
        [data retain];
        isRetained = YES;
    }
    
    return self;
}

-(id)contentAutoreleased {
    
    if (isRetained) {
        [header autorelease];
        [data autorelease];
        isRetained = NO;
    }

    return self;
}

@end
