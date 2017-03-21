//
//  IProtocolFormatter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"
#import "FlashorbBinaryWriter.h"
#import "ReferenceCache.h"

@protocol IObjectSerializer;

@interface IProtocolFormatter : NSObject {
	NSMutableDictionary		*cachedWriters;
	id <ITypeWriter>		contextWriter;
	FlashorbBinaryWriter	*writer;
	long					beginSelectBytesIndex;
}
@property (nonatomic, assign) id <ITypeWriter> contextWriter;
@property (nonatomic, assign) FlashorbBinaryWriter *writer;

+(id)formatter;
// caching purposes
-(void)beginSelectCacheObject;
-(id)endSelectCacheObject;
-(void)writeCachedObject:(id)cached;
// reference cache
-(ReferenceCache *)getReferenceCache;
-(void)resetReferenceCache;
// type mapping
-(id <ITypeWriter>)getWriter:(Class)type;
-(id <ITypeWriter>)getCachedWriter:(Class)type;
-(void)addCachedWriter:(Class)type writer:(id <ITypeWriter>)typeWriter;
// data type serialization
-(void)beginWriteMessage:(id)message;
-(void)endWriteMessage;
-(void)writeMessageVersion:(float)version;
-(void)beginWriteBodyContent;
-(void)endWriteBodyContent;
-(void)beginWriteArray:(int)length;
-(void)endWriteArray;
-(void)writeBoolean:(BOOL)b;
-(void)writeDate:(NSDate *)datetime;
-(void)beginWriteObjectMap:(int)size;
-(void)endWriteObjectMap;
-(void)writeFieldName:(NSString *)s;
-(void)beginWriteFieldValue;
-(void)endWriteFieldValue;
-(void)writeNull;
-(void)writeDouble:(double)number;
-(void)writeInteger:(double)number;
-(void)beginWriteNamedObject:(NSString *)objectName fields:(int)fieldCount;
-(void)endWriteNamedObject;
-(void)beginWriteObject:(int)fieldCount;
-(void)endWriteObject;
-(void)writeArrayReference:(int)refID;
-(void)writeObjectReference:(int)refID;
-(void)writeDateReference:(int)refID;
-(void)writeStringReference:(int)refID;
-(void)writeString:(NSString *)s;
-(void)writeData:(NSData *)data;
-(id <IObjectSerializer>)getObjectSerializer;
@end
