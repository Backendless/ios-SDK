//
//  AmfFormatter.m
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

#import "AmfFormatter.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "IObjectSerializer.h"
#import "BinaryCodec.h"

@implementation AmfFormatter

-(id)init {	
	if ( (self=[super init]) ) {
        objectSerializer = [[ObjectSerializer alloc] init];
		referenceCache = [[ReferenceCache alloc] init];
	}
	
	return self;
}

+(id)formatter {
    return [[AmfFormatter new] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AmfFormatter"];
	
	[referenceCache release];
    [objectSerializer release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

#pragma mark -
#pragma mark IProtocolFormatter Methods

-(ReferenceCache *)getReferenceCache {
	return referenceCache;
}

-(void)resetReferenceCache {
	[referenceCache reset];
}

-(void)writeMessageVersion:(float)version {
	[writer writeUInt16:(unsigned short)version];
}

-(void)beginWriteArray:(int)length {
	[writer writeByte:ARRAY_DATATYPE_V1];
	[writer writeUInteger:length];
}

-(void)writeBoolean:(BOOL)b {
	[writer writeByte:BOOLEAN_DATATYPE_V1];
	[writer writeBoolean:b];
}

-(void)writeDate:(NSDate *)datetime {
	[writer writeByte:DATE_DATATYPE_V1];
	[writer writeDouble:[datetime timeIntervalSince1970]*1000];
	[writer writeUInt16:0];
}

-(void)beginWriteObjectMap:(int)size {
	[writer writeByte:OBJECTARRAY_DATATYPE_V1];
	[writer writeUInteger:size];
}

-(void)endWriteObjectMap {
	[writer writeUInteger:0];
	[writer writeByte:ENDOFOBJECT_DATATYPE_V1];
}

-(void)writeFieldName:(NSString *)s {
	[writer writeString:s];
}

-(void)writeNull {
	[writer writeByte:NULL_DATATYPE_V1];
}

-(void)writeDouble:(double)number {
	[writer writeByte:NUMBER_DATATYPE_V1];
	[writer writeDouble:number];
}

-(void)writeInteger:(double)number {
	[writer writeByte:NUMBER_DATATYPE_V1];
	[writer writeDouble:number];
}

-(void)beginWriteNamedObject:(NSString *)objectName fields:(int)fieldCount {
	[writer writeByte:NAMEDOBJECT_DATATYPE_V1];
	[writer writeString:objectName];
}

-(void)endWriteNamedObject {
	[writer writeUInteger:0];
	[writer writeByte:ENDOFOBJECT_DATATYPE_V1];
}

-(void)beginWriteObject:(int)fieldCount {
	[writer writeByte:OBJECT_DATATYPE_V1];
}

-(void)endWriteObject {
	[writer writeUInt16:0];
	[writer writeByte:ENDOFOBJECT_DATATYPE_V1];
}

-(void)writeArrayReference:(int)refID {
	[writer writeByte:POINTER_DATATYPE_V1];
	[writer writeUInt16:(unsigned short)refID];
}

-(void)writeObjectReference:(int)refID {
	[writer writeByte:POINTER_DATATYPE_V1];
	[writer writeUInt16:(unsigned short)refID];
}

-(void)writeDateReference:(int)refID {
	[writer writeByte:POINTER_DATATYPE_V1];
	[writer writeUInt16:(unsigned short)refID];
} 

-(void)writeStringReference:(int)refID {
	[writer writeByte:POINTER_DATATYPE_V1];
	[writer writeUInt16:(unsigned short)refID];
}

-(void)writeString:(NSString *)s {
    if (s.length < 0x10000) {
        [writer writeByte:UTFSTRING_DATATYPE_V1];
        [writer writeString:s];
    }
    else {
        [writer writeByte:LONGUTFSTRING_DATATYPE_V1];
        [writer writeLongString:s];
    }
}

-(void)writeData:(NSData *)data {
	[writer writeByte:V3_DATATYPE];
	[writer writeByte:BYTEARRAY_DATATYPE_V3];
	[writer writeVarInt:(int)((data.length << 1)|0x1)];
	[writer write:(char *)data.bytes length:data.length];
}

-(id <IObjectSerializer>)getObjectSerializer {
    return  objectSerializer;
}

@end
