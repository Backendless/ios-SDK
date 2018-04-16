//
//  IProtocolFormatter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IProtocolFormatter.h"
#import "DEBUG.h"
#import "BinaryStream.h"
#import "Types.h"

@implementation IProtocolFormatter
@synthesize contextWriter, writer;

-(id)init {	
	if ( (self=[super init]) ) {
		cachedWriters = [NSMutableDictionary new];
		contextWriter = nil;
		writer = [[FlashorbBinaryWriter alloc] initWithAllocation:1];
		beginSelectBytesIndex = 0;
	}
	
	return self;
}

+(id)formatter {
    return [[IProtocolFormatter new] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC IProtocolFormatter"];
	
	[cachedWriters release];
	[writer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

// caching purposes

-(void)beginSelectCacheObject {
	beginSelectBytesIndex = writer.size;
}

-(id)endSelectCacheObject {
	
	if (writer.size < beginSelectBytesIndex)
		return [[[BinaryStream alloc] initWithAllocation:1] autorelease];
	
	size_t len = writer.size - beginSelectBytesIndex;
	return [[[BinaryStream alloc] initWithStream:&writer.buffer[len] andSize:len] autorelease];
}

-(void)writeCachedObject:(id)cached {
	NSData *array = (NSData *)cached;
	[writer write:(char *)array.bytes length:array.length];
}

-(ReferenceCache *)getReferenceCache {
	return nil;
}

-(void)resetReferenceCache {
}

// type mapping

-(id <ITypeWriter>)getWriter:(Class)type {
	return nil;
}

-(id <ITypeWriter>)getCachedWriter:(Class)type {
	return [cachedWriters objectForClassKey:type];
}

-(void)addCachedWriter:(Class)type writer:(id <ITypeWriter>)typeWriter {
	if (typeWriter) [cachedWriters setObject:typeWriter forClassKey:type];
}

// data type serialization

-(void)beginWriteMessage:(id)message {
}

-(void)endWriteMessage {
}

-(void)writeMessageVersion:(float)version {
}

-(void)beginWriteBodyContent {
}

-(void)endWriteBodyContent {
}

-(void)beginWriteArray:(int)length {
}

-(void)endWriteArray {
}

-(void)writeBoolean:(BOOL)b {
}

-(void)writeDate:(NSDate *)datetime {
}

-(void)beginWriteObjectMap:(int)size {
}

-(void)endWriteObjectMap {
}

-(void)writeFieldName:(NSString *)s {
}

-(void)beginWriteFieldValue {
}

-(void)endWriteFieldValue {
}

-(void)writeNull {
}

-(void)writeDouble:(double)number {
}

-(void)writeInteger:(double)number {
}

-(void)beginWriteNamedObject:(NSString *)objectName fields:(int)fieldCount {
}

-(void)endWriteNamedObject {
}

-(void)beginWriteObject:(int)fieldCount {
}

-(void)endWriteObject {
}

-(void)writeArrayReference:(int)refID {
}

-(void)writeObjectReference:(int)refID {
}

-(void)writeDateReference:(int)refID {
} 
 
-(void)writeStringReference:(int)refID {
}

-(void)writeString:(NSString *)s {
}

-(void)writeData:(NSData *)data {  
}

-(id <IObjectSerializer>)getObjectSerializer {
    return nil;
}


@end
