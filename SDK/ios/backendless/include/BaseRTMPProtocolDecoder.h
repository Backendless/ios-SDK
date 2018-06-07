//
//  BaseRTMPProtocolDecoder.h
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
