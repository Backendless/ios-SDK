//
//  Aggregate.m
//  RTMPStream
//
//  Created by Dmytro Krasikov on 10/7/11.
//  Created by Vyacheslav Vdovichenko on 4/25/12.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Aggregate.h"
#import "DEBUG.h"
#import "BinaryStream.h"
#import "AudioData.h"
#import "VideoData.h"
#import "RTMPConstants.h"

@implementation Aggregate

-(id)init {
	if ( (self=[super initWithType:STREAM_DATA]) ) {
        data = [[BinaryReader alloc] initWithAllocation:1];
	}
	
	return self;    
}

-(id)initWithStream:(char *)stream andSize:(size_t)length {
	if ( (self=[super initWithType:STREAM_DATA]) ) {
        data = [[BinaryReader alloc] initWithStream:stream andSize:length];
	}
	
	return self;    
}

-(void)dealloc {
	
	[DebLog log:@"DEALLOC Aggregate"];
    
    [data release]; 
	
	[super dealloc];
}

-(NSArray*)getEvents {
    
    NSMutableArray* parts = [NSMutableArray array];
    
    uint streamId = (header) ? header.streamId : 0;
    
    while ([data remaining]) {
        
        // read the current packet header
        char subType = [data readChar];
        uint size = [data readUInt24BE];
        uint _timestamp = [data readUInt24BE];
        uint _streamId = [data readUInt32BE];
        
        [DebLog log:@"Aggregate -> getEvents: streamId = %d, subType = %d size = %d, timestamp: %u", _streamId, subType, size, _timestamp];
        
        if ([data remaining] < size) {
            [DebLog logY:@"Aggregate -> getEvents: (ERROR)  size: %d < %d ?",  size, [data remaining]];
            break;
        }
        
        Header *_header = [Header header]; 
        _header.dataType = subType;
        _header.size = size;
        _header.streamId = streamId; // use the stream id from the aggregate's header
        [_header setTimer:_timestamp];
        
        BinaryReader *streamData = [[BinaryReader alloc] initWithStream:(data.buffer+data.position) andSize:size];
        // skip one packet
        [data seek:(data.position+size)];
        
        switch (subType) {
            
            case TYPE_AUDIO_DATA: {
                AudioData *audio = [[AudioData alloc] initWithBinaryStream:streamData];
                audio.timestamp = _timestamp;
                audio.header = _header;
                [parts addObject:audio];
                break;
            }
            
            case TYPE_VIDEO_DATA: {    
                VideoData *video = [[VideoData alloc] initWithBinaryStream:streamData];
                video.timestamp = _timestamp;
                video.header = _header;
                [parts addObject:video];
                break;
            }
            
            default:
                [DebLog logY:@"Aggregate -> getEvents: non media subType = %d", subType];
        }
        
        // the back pointer may be used to verify the size of the individual part
        // it will be equal to the data size + header size
        uint backPointer = [data readUInt32BE];
        if (backPointer != size) {
            [DebLog logY:@"Aggregate -> getEvents: (ERROR) Data size (%d) and back pointer (%d) did not match", size, backPointer];
            break;
        }
    } 

    return parts;
}

-(uint)getDataType {
	return TYPE_AGGREGATE;
}

@end
