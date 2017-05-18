//
//  AmfV3Formatter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AmfV3Formatter.h"
#import "MessageWriter.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "IObjectSerializer.h"
#import "V3ObjectSerializer.h"
#import "BinaryCodec.h"
#import "Types.h"


@implementation AmfV3Formatter

-(id)init {	
	if( (self=[super init]) ) {
		writers = [NSMutableDictionary new];
        objectSerializer = [V3ObjectSerializer new];
		referenceCache = [V3ReferenceCache new];
	}
	
	return self;
}

+(id)formatter {
    return [[AmfV3Formatter new] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AmfV3Formatter"];
	
	[writers removeAllObjects];
	[writers release];
	
	[referenceCache release];
    [objectSerializer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(void)writeStringOrReferenceId:(NSString *)s {
	int refId = [referenceCache getStringId:s];
	if (refId != -1) {
		[writer writeVarInt:(refId << 1)];
	}
	else {
		[referenceCache addString:s];
        [writer writeStringEx:s];
	}
}

#pragma mark -
#pragma mark Public Methods

-(void)addTypeWriter:(Class)mappedType writer:(id <ITypeWriter>)typeWriter {
	[writers setObject:typeWriter forClassKey:mappedType];
}

-(void)writeByteArray:(NSData *)array {
	[writer writeByte:BYTEARRAY_DATATYPE_V3];
	[writer writeVarInt:(int)((array.length << 1)|0x1)];
	[writer write:(char *)array.bytes length:array.length];
}

-(void)writeDouble:(double)number withMarker:(BOOL)writeMarker {
	if (writeMarker)
		[writer writeByte:DOUBLE_DATATYPE_V3];
	[writer writeDouble:number];
}

-(void)writeUncompressedUInteger:(uint)number {
	[writer writeUInteger:number];
}

-(void)writeUncompressedInteger:(int)number {
	[writer writeInt:number];
}

-(void)writeVarIntWithoutMarker:(int)number {
	[writer writeVarInt:number];
}

-(void)writeString:(NSString *)s withMarker:(BOOL)writeMarker {
	if (writeMarker)
		[writer writeByte:UTFSTRING_DATATYPE_V3];
	if (s.length) 
        [writer writeStringEx:s];
	else 
		[writer writeByte:0x1];
}

#pragma mark -
#pragma mark IProtocolFormatter Methods

-(id <ITypeWriter>)getWriter:(Class)type {
	return [writers objectForClassKey:type];
}

-(ReferenceCache *)getReferenceCache {
	return referenceCache;
}

-(void)resetReferenceCache {
	[referenceCache reset];
}

-(void)writeMessageVersion:(float)version {
	[writer writeUInt16:(unsigned short)version];
}

-(void)beginWriteBodyContent {
	[writer writeByte:V3_DATATYPE];
}

-(void)beginWriteArray:(int)length {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> beginWriteArray:%d", length];
	
	[writer writeByte:ARRAY_DATATYPE_V3];
	[writer writeVarInt:((length << 1)|0x1)];
	[writer writeVarInt:0x1];
}

-(void)writeBoolean:(BOOL)b {
    [writer writeByte:b?BOOLEAN_DATATYPE_TRUEV3:BOOLEAN_DATATYPE_FALSEV3];
}

-(void)writeDate:(NSDate *)datetime {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeDate:%@", datetime];
	
	[writer writeByte:DATE_DATATYPE_V3];
	[writer writeVarInt:0x1];	
	[writer writeDouble:[datetime timeIntervalSince1970]*1000];
}

-(void)beginWriteObjectMap:(int)size {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> beginWriteObjectMap:%d", size];
	
	[writer writeByte:OBJECT_DATATYPE_V3];
	[writer writeVarInt:((size << 4)|0x3)]; // classInfo with size of the property count
	[writer writeVarInt:0x1];				// no classname
}

-(void)writeFieldName:(NSString *)s {
#if _ON_REFERENCEBLE_STRING_WRITER_
    [self writeStringOrReferenceId:s];
#else
    [writer writeStringEx:s];
#endif
}

-(void)writeNull {
	[writer writeByte:NULL_DATATYPE_V3];
}

-(void)writeInteger:(double)number {
	if ((number >= -268435456) && (number <= 268435455)) {
		[writer writeByte:INTEGER_DATATYPE_V3];
		[writer writeVarInt:((int)number & 0x1fffffff)];
	}
	else {
		[writer writeByte:DOUBLE_DATATYPE_V3];
		[writer writeDouble:number];
	}
}

-(void)writeDouble:(double)number {
	[writer writeByte:DOUBLE_DATATYPE_V3];
	[writer writeDouble:number];
}

-(void)beginWriteNamedObject:(NSString *)objectName fields:(int)fieldCount {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> beginWriteNamedObject:%@ fields:%d", objectName, fieldCount];
	
	[writer writeByte:OBJECT_DATATYPE_V3];
	[writer writeVarInt:((fieldCount << 4)|0x3)]; 
	if (objectName) {
#if _ON_REFERENCEBLE_STRING_WRITER_
		[self writeStringOrReferenceId:objectName];
        [referenceCache addToTraitsCache:objectName];
#else
        [writer writeStringEx:objectName];
#endif
	}
	else
		[writer writeVarInt:0x1];			// no classname	
}

-(void)beginWriteObject:(int)fieldCount {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> beginWriteObject:%d", fieldCount];
	
	[writer writeByte:OBJECT_DATATYPE_V3];
	[writer writeVarInt:((fieldCount << 4)|0x3)]; 
	[writer writeVarInt:0x1];				// no classname
}

-(void)endWriteObject {
}

-(void)writeArrayReference:(int)refID {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeArrayReference:%d", refID];
	
	[writer writeByte:ARRAY_DATATYPE_V3];
	[writer writeVarInt:(refID << 1)];
}

-(void)writeObjectReference:(int)refID {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeObjectReference:%d", refID];
	
	[writer writeByte:OBJECT_DATATYPE_V3];
	[writer writeVarInt:(refID << 1)];
}

-(void)writeDateReference:(int)refID {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeDateReference:%d", refID];
	
	[writer writeByte:DATE_DATATYPE_V3];
	[writer writeVarInt:(refID << 1)];
} 

-(void)writeStringReference:(int)refID {
	
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeStringReference:%d", refID];
	
	[writer writeByte:UTFSTRING_DATATYPE_V3];
	[writer writeVarInt:(refID << 1)];
}

-(void)writeString:(NSString *)s {
	[self writeString:s withMarker:YES];
}

-(void)writeData:(NSData *)data {
#if 0
    NSString *enc = [BEBase64 encode:data];
	[DebLog log:_ON_WRITERS_LOG_ text:@">>>>>>>>>> AmfV3Formatter -> writeData:%@", enc];
    [self writeString:enc];
#else
    [self writeByteArray:data];
#endif
}

-(id <IObjectSerializer>)getObjectSerializer {
    return  objectSerializer;
}
	
@end
