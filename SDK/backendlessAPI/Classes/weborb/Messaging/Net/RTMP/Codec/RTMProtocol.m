//
//  RTMProtocol.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 05.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "RTMProtocol.h"
#import "DEBUG.h"
#import "RTMPConstants.h"
#import "Header.h"
#import "Packet.h"
#import "CrowdNode.h"
#import "BinaryStream.h"
#import "FlashorbBinaryReader.h"
#import "FlashorbBinaryWriter.h"
#import "BaseRTMPProtocolDecoder.h"

#define IS_DISPATCH_QUEUE 0

@interface RTMProtocol () {
	
#if IS_DISPATCH_QUEUE
    // dispatch queue
    dispatch_queue_t    decoderDispatchQueue;
#endif
    
    // delegate
	id <IRTMProtocol>   delegate;
	
	// context
	NSMutableArray	*outputChunks;
	NSMutableArray	*inputChunks;
	CrowdNode		*writeHeaders;
	CrowdNode		*readHeaders;
	NSMutableArray	*writing;
	CrowdNode		*reading;
	
	int				readChunkSize;
	int				writeChunkSize;
	int             breakChunkSize;
    BOOL            isMergeChunkLocked;
    BOOL            isMergeChunkNeeded;
    
    // typed packet counters
    int             countVideoPacket;
    
    // debug
    BOOL            dumpOn;
}

-(void)defaultInitialize;
-(RTMPHeaderType)fixWriteHeader:(Header *)header;
-(void)splitChunk;
-(void)mergeChunk;
@end


@implementation RTMProtocol
@synthesize delegate, readChunkSize, writeChunkSize; 

-(id)init {
	if ( (self=[super init]) ) {		
		[self defaultInitialize];
	}
	return self;
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC RTMProtocol"];
	
	[self clearContext];
	
	[outputChunks release];
	[inputChunks release];
	[writeHeaders release];
	[readHeaders release];
	[writing release];
	[reading release];
    
#if IS_DISPATCH_QUEUE
    dispatch_release(decoderDispatchQueue);
#endif
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)defaultInitialize {
	
	[DebLog logN:@"RTMProtocol -> defaultInitialize"];
    
#if IS_DISPATCH_QUEUE
    // create a serial dispatch queue
    NSString *queueName = [NSString stringWithFormat:@"com.themidnightcoders.RTMProtocol.%@", [NSString randomString:12]];
    decoderDispatchQueue = dispatch_queue_create([queueName UTF8String], NULL);
#endif
	
	readChunkSize = DEFAULT_CHUNK_SIZE;
	writeChunkSize = DEFAULT_CHUNK_SIZE;
    breakChunkSize = 0;
    isMergeChunkLocked = NO;
    isMergeChunkNeeded = NO;
	
	outputChunks = [NSMutableArray new];
	inputChunks = [NSMutableArray new];
	writeHeaders = [CrowdNode new];
	readHeaders = [CrowdNode new];
	writing = [NSMutableArray new];
	reading = [CrowdNode new];
    
    countVideoPacket = 0;
    
    dumpOn = YES;
}

#if 1 // old implementation - works

-(RTMPHeaderType)fixWriteHeader:(Header *)header {
	
	NSString *channelId = [Packet keyByChannelId:header.channelId];
	Header *lastHeader = (Header *)[writeHeaders get:channelId];
	RTMPHeaderType headerType = HEADER_NEW;
	if (lastHeader) { 		
		
		[DebLog logN:@"RTMProtocol -> fixWriteHeader: -> GET lastHeader: %@", [lastHeader toString]];
		
		if (header.streamId == lastHeader.streamId) {
			headerType = HEADER_SAME_SOURCE;
			if ((header.dataType == lastHeader.dataType) && (header.size == lastHeader.size)) {
				headerType = HEADER_TIMER_CHANGE;
				if (header.timerBase == lastHeader.timerBase)
					headerType = HEADER_CONTINUE;
			}
		}
	}
	
	[DebLog logN:@"RTMProtocol -> fixWriteHeader: -> PUSH lastHeader: %@", [header toString]];
	
	[writeHeaders push:channelId withObject:header];
	
	return headerType;	
}

#else // new implementation - breaks

-(BOOL)needLeaderMediaHeader:(Header *)header {
    return ((header.dataType == TYPE_NOTIFY) ||
            ((header.timerDelta == 0) && ((header.dataType == TYPE_AUDIO_DATA) || (header.dataType == TYPE_VIDEO_DATA))));
}

-(RTMPHeaderType)fixWriteHeader:(Header *)header {
	
    NSString *channelId = [Packet keyByChannelId:header.channelId];
    Header *last = (Header *)[writeHeaders get:channelId];
    RTMPHeaderType headerType = HEADER_NEW;
    
#if 0   // need the base & delta timestamp correction
    
    uint ts = [header getTimer];
    if (last) {
        
        uint baseTs = [last getTimer];
        if (ts > baseTs) {
            header.timerBase = baseTs;
            header.timerDelta = ts - baseTs;
        }
        else {
            header.timerBase = ts;
            header.timerDelta = 0;
        }
    }
    else {
        header.timerBase = ts;
        header.timerDelta = 0;
    }
    
#endif
   
    if (last /*&& ![self needLeaderMediaHeader:header]*/) {
        
        [DebLog logN:@"RTMProtocol -> fixWriteHeader: -> GET lastHeader: %@", [last toString]];
        
        if (header.streamId == last.streamId) {
            headerType = HEADER_SAME_SOURCE;
            if ((header.dataType == last.dataType) && (header.size == last.size)) {
                headerType = HEADER_TIMER_CHANGE;
                if (header.timerDelta == last.timerDelta)
                    headerType = HEADER_CONTINUE;
            }
        }
	}
	
    [DebLog logN:@"RTMProtocol -> fixWriteHeader: -> PUSH lastHeader: %X -> %@", headerType, [header toString]];
	
	[writeHeaders push:channelId withObject:header];
	
	return headerType;
}

#endif // new implementation - breaks

-(void)splitChunk {
	
	[DebLog logN:@"RTMProtocol -> splitChunk -> Start"];
	
	if (![writing count]) {
		
		[DebLog logN:@"RTMProtocol -> splitChunk -> Finish (empty)"];
		return;
	}
    
#if 1
    
    id obj = [writing objectAtIndex:0];
    if (!obj || ![obj isKindOfClass:[Packet class]]) {
        [DebLog logY:@"RTMProtocol -> splitChunk: (ERROR) obj <%@> is not Packet", obj];
        return;
    }
    
	Packet *packet = (Packet *)obj;
    
#else
    
	Packet *packet = [writing objectAtIndex:0];
    
#endif
    
    isMergeChunkLocked = YES;
	
    //NSLog(@" ----- packet: isRetained = %d", (int)packet.isRetained);
    //NSLog(@" ----- packet: header = %@, data = %@", packet.header, packet.data);
    
    //split an original chunk to the chunks of size == writeChunkSize
	size_t size = packet.data.size;	
    int n = ((int)size % writeChunkSize) ? (int)size/writeChunkSize + 1 : (int)size/writeChunkSize;
    
    [DebLog logN:@"\n--- Packet body size = %d, chunkSise = %d, so it needs %d chunk(s)\n", (int)size, writeChunkSize, n];
    
    // fix header 
    Packet *chunk = [Packet packet];
    chunk.header = packet.header;
    chunk.header.size = size;
   
    for (int i = 0; i < n; i++) {
        int start = i * writeChunkSize;
        int len = size - start;
        if (len > writeChunkSize) len = writeChunkSize;
        
        int begin = chunk.data.position;
        [chunk constructHeader:[self fixWriteHeader:chunk.header]];
        [chunk.data write:&packet.data.buffer[start] length:len];
        [chunk.data print:NO start:begin finish:(chunk.data.position-1)]; // CHUNK DUMP
    }
    
    [outputChunks addObject:chunk.data];
    
#if 1 // -- count TYPE_VIDEO_DATA
    if (packet.header.dataType == TYPE_VIDEO_DATA)
        countVideoPacket--;
#endif
	
    [writing removeObjectAtIndex:0];
	
	[DebLog logN:@"RTMProtocol -> splitChunk -> Finish (full) outputChanks = %d", outputChunks.count];
    
    if (isMergeChunkNeeded) 
        [self performSelector:@selector(mergeChunk) withObject:nil afterDelay:0.0f];
    
    isMergeChunkLocked = NO;
    isMergeChunkNeeded = NO;

}

-(void)removeFirstChunk:(Packet*)message {
    
    BinaryStream *chunk = (BinaryStream *)[inputChunks objectAtIndex:0];
    
    int packetSize = [message packetSize];
    if (chunk.size<packetSize){
        [DebLog logY:@"RTMProtocol -> removeFirstChunk: chunk size is less than packet size"];
    }
    if(chunk.size == packetSize) {
        [inputChunks removeObjectAtIndex:0];
        return;
    }
    
    [chunk seek:packetSize];
    [chunk shift];
}

#define _FRAGMENTATION_BUG_CATCHER_ 0

-(BOOL)readingData:(Packet*)message chunk:(BinaryStream*)chunk len:(int)len part:(NSString*)part {
    
    int size = readChunkSize + [message headerSize];
    
    [DebLog logN:@"RTMProtocol -> readingData: (%@) len: %d, size: %d, readChunkSize: %d, chunk.size: %d", part, len, size, readChunkSize, chunk.size];

    if (len > size) {
        len = size; 
    }
    
    if (chunk.size > len) {
        
        [message.data seek:len];
        [message.data trunc];
        //[message.data print:NO];
       
        [chunk seek:len];
        [chunk shift];
        //[chunk print:NO];
        
#if _FRAGMENTATION_BUG_CATCHER_ // ------- (red5 problem) -----------
        if (dumpOn) {
            
            int channelId = (int)([chunk get] & CHUNK_STREAM_MASK);
            if (channelId >= 2 && channelId <= 6) {
                [message.data print:YES start:0 finish:15];
                [chunk print:YES start:0 finish:15];
            }
            else {
                [DebLog logY:@"RTMProtocol -> readingData: (!!! BREAK !!!) len: %d, size: %d, chunk.size: %d", len, size, chunk.size];
                [message.data print:YES];
                [chunk print:YES];
                dumpOn = NO;
            }
        }
#endif // -----------------------------------------------------------
        
    }
    else {
        
        breakChunkSize = len - chunk.size;
        if (breakChunkSize) {
            // it's fragmental chunk: wait next partition
            [DebLog logN:@"RTMProtocol -> readingData: (%@) fragmental chunk: breakChunkSize = %d", part, breakChunkSize];
            [message release];
            return NO;                
        }
        
        // chunk size is equal to message size so remove it completely
        [inputChunks removeObjectAtIndex:0];
        
#if _FRAGMENTATION_BUG_CATCHER_
        [message.data print:dumpOn start:0 finish:15];
#endif
    }
    
    return YES;
}

-(void)receivedMessage:(Packet *)message {
    if ([delegate respondsToSelector:@selector(receivedMessage:)])
        [delegate performSelector:@selector(receivedMessage:) withObject:message];
}

#define _MERGE_CHANK_ NO

-(void)mergeChunk {
	
	[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: Start [%@]", [NSThread isMainThread]?@"M":@"T"];
	
	while (inputChunks.count) {
		
		BinaryStream *chunk = (BinaryStream *)[inputChunks objectAtIndex:0];
        
        // fragmental chunk merging
        if (breakChunkSize) {
            
            if (inputChunks.count == 1) {
                [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: Finish 0"];
                return;  // wait next chunk
            }
            
            // append chunk by next           
            BinaryStream *next = (BinaryStream *)[inputChunks objectAtIndex:1];          
            if ([chunk append:next.buffer length:next.size]) {
                [chunk print:NO];
                [inputChunks removeObjectAtIndex:1];
            }
            else {
                // ignore the fragmental chunk
                if (breakChunkSize > 0) {
                    [DebLog logY:@"RTMProtocol -> mergeChunk: (ERROR) fragmental chunk cann't merge - it is clearing"];
                    [inputChunks removeObjectAtIndex:0];
                    chunk = next;
                    [chunk seek:breakChunkSize];
                    [chunk shift];
                    [chunk print:YES];
                }
                else {
                    [DebLog logY:@"RTMProtocol -> mergeChunk: (FATAL ERROR) header is absent - input chunks are clearing"];
                    [inputChunks removeAllObjects];
                    [reading clear];
                    breakChunkSize = 0;
                    continue;
                }
            }
           
            breakChunkSize = 0;
        }
		
		// chunk processing
        int headerType = (int)(([chunk get] & CHUNK_HEADER_MASK) >> 6);
		if (headerType == HEADER_NEW) {
			
            //--------- process the first header of new packet
			Packet *message = [[Packet alloc] initWithRetainedData:chunk.buffer ofSize:chunk.size];
            [chunk print:NO];
			if (!message.header.size) {
                if (chunk.size > 11) {
                    
                    [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (ERROR) chunk with zero-length message - ignore it"];
                    [chunk print:_MERGE_CHANK_];
                    
                    // delete empty chunk
                    [self removeFirstChunk:message];
                    [reading clear];
                }
                else {
                    // it's fragmental chunk: wait next partition
                    breakChunkSize = -1;
                    [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (FRAGMENTAL H1) breakChunkSize = %d", breakChunkSize];
                }
                [message release];
				continue;
			}

            if (![self readingData:message chunk:chunk len:[message packetSize] part:@"A"])
                continue;
			
			// clear header from data
			[message clearHeaderFromData];
			
			// save the header for channelId
			NSString *channelId = [message keyByChannelId];
			[readHeaders push:channelId withObject:message.header];
			
			// clear pending message for channelId
			[reading del:channelId];
			// pending | received
			if ([message pendingSize] > 0) {
				[reading push:channelId withObject:message];
                [DebLog log:NO text:@"RTMProtocol ->  mergeChunk: (1) reading = %d", [reading count]];
            }
			else {
                [self receivedMessage:message];
			}
			
			[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (FIRST HEADER) '%@' for channelId = %@", [message.header toString], channelId];
			[DebLog logN:@"RTMProtocol -> mergeChunk: readHeaders = %d, reading = %d", [readHeaders count], [reading count]];
            
            [message release];
			continue;
		}
		
		//--------- construct the last header
		FlashorbBinaryReader *input = [[FlashorbBinaryReader alloc] initWithStream:chunk.buffer andSize:chunk.size];		
		int chunkId = [BaseRTMPProtocolDecoder chunkStreamID:input];
		NSString *channelId = [Packet keyByChannelId:chunkId];
		Header *lastHeader = nil;
		if (chunkId > 1) 
			lastHeader = (Header *)[readHeaders get:channelId];
		if (!lastHeader) {
            lastHeader = [Header header];
            lastHeader.streamId = 1;
		}
#if 0
        if (lastHeader.channelId != chunkId) {
            [DebLog log:YES text:@"RTMProtocol -> mergeChunk: (!!! NOT CORRECT !!!) headerType = %d <%d != %d> ", headerType, lastHeader.channelId, chunkId];
            [input print:NO];
        }
#endif
		[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: GET lastHeader '%@' for channelId = %@", [lastHeader toString], channelId];
		
		[input begin];
		lastHeader = [BaseRTMPProtocolDecoder chunkHeader:input lastHeader:lastHeader];
		[input release];
        
        if (!lastHeader) {
            // it's fragmental chunk: wait next partition
            breakChunkSize = -1;
            [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (FRAGMENTAL H2) breakChunkSize = %d", breakChunkSize];
            continue;
        }
		
        [readHeaders push:channelId withObject:lastHeader];
		
		[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: PUSH lastHeader '%@' for channelId = %@", [lastHeader toString], channelId];
		
		//-------- merge the chunks for chunkId
		FlashorbBinaryWriter *data = [[FlashorbBinaryWriter alloc] initWithStream:chunk.buffer andSize:chunk.size];
        Header *header = [[Header alloc] initWithHeader:lastHeader]; 
		Packet *message = [[Packet alloc] initWithHeader:header andData:data];
        message.isRetained = YES; //***
        Packet *packet = [reading get:channelId];

        if (!packet || (headerType == HEADER_SAME_SOURCE)) {

            //--------- process the new packet
            if (![self readingData:message chunk:chunk len:[message packetSize] part:@"B"])
                continue;
		
            // clear the header from data
            [message clearHeaderFromData];
		
            // clear pending message for channelId
            [reading del:channelId];
            // pending | received
            if ([message pendingSize] > 0) {
                [reading push:channelId withObject:message];
                [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol ->  mergeChunk: (2) reading = %d", [reading count]];
            }
            else {
                [self receivedMessage:message];
            }
        }
        else { 
            
            //--------- process the pending packet
            if (![self readingData:message chunk:chunk len:([packet pendingSize] + [message headerSize]) part:@"C"])
                continue;
            
            // clear the header from data
            [message clearHeaderFromData];
            
            // add message.data to pending packet.data
            [packet.data end];
            [packet.data write:message.data.buffer length:message.data.size];
            
            // pending | received
            if ([packet pendingSize] > 0) {
                [DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (3) reading = %d, packet.data.size = %d", [reading count], packet.data.size];
            }
            else {
                [self receivedMessage:packet];
                
                // clear pending message for channelId
                [reading del:channelId];
            }           
        }
		
		[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: (0) readHeaders = %d, reading = %d", [readHeaders count], [reading count]];
        
        [message release];		
		continue;
	}
	
	[DebLog log:_MERGE_CHANK_ text:@"RTMProtocol -> mergeChunk: Finish 1"];
}

#pragma mark -
#pragma mark Public Methods

-(void)clearContext {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	
    [outputChunks removeAllObjects];
	[inputChunks removeAllObjects];
	[writeHeaders clear];
	[readHeaders clear];
	[writing removeAllObjects];
	[reading clear];
    
    countVideoPacket = 0;
}

-(BinaryStream *)sendingChunk {
	
	if (!outputChunks.count) 
		[self splitChunk];
	
	return (outputChunks.count) ? (BinaryStream *)[outputChunks objectAtIndex:0] : nil;
}

-(void)sentChunk {
	if (outputChunks.count) 
		[outputChunks removeObjectAtIndex:0];		
}

-(void)receivedChunk:(BinaryStream *)chunk {
	
    [inputChunks addObject:chunk];

#if IS_DISPATCH_QUEUE
    dispatch_async(decoderDispatchQueue, ^{
        [self mergeChunk];
    });
#else
    if (!isMergeChunkLocked) {
        [self performSelector:@selector(mergeChunk) withObject:nil afterDelay:0.0f];
    }
    else
        isMergeChunkNeeded = YES;
#endif

	[DebLog logN:@"RTMProtocol -> receivedChunk: inputChunks.count = %d", inputChunks.count];
}

-(BOOL)shouldSendMessage {
	return (outputChunks.count == 0);
}

-(BOOL)sendMessage:(Packet *)message {
    
    @synchronized (self) {
        
        [writing addObject:[message contentRetained]];
        
#if 1 // ++ TYPE_VIDEO_DATA count
        if (message.header.dataType == TYPE_VIDEO_DATA)
            countVideoPacket++;
#endif
    }
    
    return YES;
}

-(Header *)lastHeader:(uint)channelId {
    return (Header *)[writeHeaders get:[Packet keyByChannelId:channelId]];
}

-(NSArray *)writingQueue {
    
    @synchronized (self) {
        return writing;
    }
}

-(int)pendingTypedPackets:(int)type streamId:(int)streamId {
    
#if 1
    return countVideoPacket;
#else
    
    int packets = 0;
    
    @synchronized (self) {
        
        @try {
            NSArray *messages = [writing copy];
            for (Packet *packet in messages) {
                if (packet.header.dataType == type && (!streamId || (packet.header.streamId == streamId)))
                    ++packets;
            }
        }
        @catch (NSException *exception) {
            [DebLog logY:@"RTMProtocol -> pendingTypedPackets: EXCEPTION <%@>", exception];
        }
    }
    
    return packets;
#endif
}

@end
