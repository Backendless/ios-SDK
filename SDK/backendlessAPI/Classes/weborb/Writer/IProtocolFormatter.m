//
//  IProtocolFormatter.m
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
