//
//  AmfV3Formatter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProtocolFormatter.h"
#import "V3ReferenceCache.h"
#import "IObjectSerializer.h"

@interface AmfV3Formatter : IProtocolFormatter {
	NSMutableDictionary     *writers;
    id <IObjectSerializer>  objectSerializer;
	V3ReferenceCache        *referenceCache;
}

-(void)addTypeWriter:(Class)mappedType writer:(id <ITypeWriter>)typeWriter;
-(void)writeByteArray:(NSData *)array;
-(void)writeDouble:(double)number withMarker:(BOOL)writeMarker;
-(void)writeUncompressedUInteger:(uint)number;
-(void)writeUncompressedInteger:(int)number;
-(void)writeVarIntWithoutMarker:(int)number;
-(void)writeString:(NSString *)s withMarker:(BOOL)writeMarker;
@end
