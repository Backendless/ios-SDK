//
//  AMFSerializer.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 29.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AMFSerializer.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "AmfFormatter.h"
#import "AmfV3Formatter.h"
#import "FlashorbBinaryReader.h"
#import "IProtocolFormatter.h"
#import "MessageWriter.h"
#import "IAdaptingType.h"
#import "RequestParser.h"
#import "StringWriter.h"


@implementation AMFSerializer

#pragma mark -
#pragma mark Private Methods

+(NSString *)filePath:(NSString *)fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    return [documentsDirectory stringByAppendingFormat:@"/%@", fileName];
}

#pragma mark -
#pragma mark Public Methods

+(BinaryStream *)serializeToBytes:(id)obj {
    return [AMFSerializer serializeToBytes:obj type:AMF3];
}

+(BinaryStream *)serializeToBytes:(id)obj type:(int)serializationType {
    
    [DebLog logN:@"AMFSerializer -> serializeToBytes: serializationType=%d", serializationType];
    
    IProtocolFormatter *formatter = (serializationType == AMF0) ? [[AmfFormatter alloc] init] : [[AmfV3Formatter alloc] init];
    [[MessageWriter sharedInstance] writeObject:obj format:formatter];
    
    BinaryStream *stream = [[[BinaryStream alloc] initWithStream:formatter.writer.buffer andSize:formatter.writer.size] autorelease];
    [formatter release];

    return stream;
}

+(id)deserializeFromBytes:(BinaryStream *)bytes {
    return [AMFSerializer deserializeFromBytes:bytes adapt:NO];
}

+(id)deserializeFromBytes:(BinaryStream *)bytes adapt:(BOOL)doNotAdapt {
    return [AMFSerializer deserializeFromBytes:bytes adapt:doNotAdapt type:AMF3];
}

+(id)deserializeFromBytes:(BinaryStream *)bytes adapt:(BOOL)doNotAdapt type:(int)serializationType {
    
    FlashorbBinaryReader *reader = [[FlashorbBinaryReader alloc] initWithStream:bytes.buffer andSize:bytes.size];
    id <IAdaptingType> type = [RequestParser readData:reader version:AMF3];
    
    return (!type || doNotAdapt) ? type : [type defaultAdapt];
}

+(BOOL)serializeToFile:(id)obj fileName:(NSString *)fileName {
    
    if (!fileName || (fileName.length == 0))
        return NO;
    
    if (!obj)
        obj = [NSNull null];

    BinaryStream *stream = [AMFSerializer serializeToBytes:obj];
    NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
    
    return [data writeToFile:[AMFSerializer filePath:fileName] atomically:YES];
}

+(id)deserializeFromFile:(NSString *)fileName {
    
    if (!fileName || (fileName.length == 0))
        return nil;
    
    NSData *data = [NSData dataWithContentsOfFile:[AMFSerializer filePath:fileName]];
    [DebLog logN:@"AMFSerializer -> deserializeFromFile: data=%@", data];
    if (!data)
        return nil;
    
    BinaryStream *stream = [BinaryStream streamWithStream:(char *)[data bytes] andSize:data.length];
    id obj = [AMFSerializer deserializeFromBytes:stream];
    return  [(NSObject *)obj isKindOfClass:[NSNull class]]?nil:obj;
}

@end
