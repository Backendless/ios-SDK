//
//  BaseRTMPProtocolDecoder.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Header, Packet, FlashorbBinaryReader;
@protocol IDeserializer;

@interface BaseRTMPProtocolDecoder : NSObject {
	id <IDeserializer>	decoder;
	Packet				*event;
	FlashorbBinaryReader *input;
}

-(id)initWithDecoder:(id <IDeserializer>)deserializer;
+(id)decoder;
+(id)decoder:(id <IDeserializer>)deserializer;
-(void)setDeserializer:(id <IDeserializer>)deserializer;
+(int)chunkStreamID:(FlashorbBinaryReader *)input;
+(Header *)chunkHeader:(FlashorbBinaryReader *)input lastHeader:(Header *)last;
-(BOOL)decodePacket:(Packet *)packet;
@end
