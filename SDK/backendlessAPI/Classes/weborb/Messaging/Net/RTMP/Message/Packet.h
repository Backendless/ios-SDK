//
//  Packet.h
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
#import "RTMPConstants.h"

@class Header, FlashorbBinaryWriter;
@protocol IRTMPEvent;

@interface Packet : NSObject {
	Header					*header;
	FlashorbBinaryWriter	*data;
	id <IRTMPEvent>			message;
	BOOL					isHeader;
    BOOL                    isRetained;
}
@property (nonatomic, assign) Header *header;
@property (nonatomic, assign) FlashorbBinaryWriter *data;
@property (nonatomic, assign) id <IRTMPEvent> message;
@property (readonly) BOOL isHeader;
@property (readwrite) BOOL isRetained;

-(id)initRetained;
-(id)initWithHeader:(Header *)head andData:(FlashorbBinaryWriter *)stream;
-(id)initWithHeader:(Header *)head andEvent:(id <IRTMPEvent>)event;
-(id)initWithData:(char *)buffer ofSize:(size_t)size;
-(id)initWithRetainedData:(char *)buffer ofSize:(size_t)size;
+(id)packet;
+(id)packetWithHeader:(Header *)head andData:(FlashorbBinaryWriter *)stream;
+(id)packetWithHeader:(Header *)head andEvent:(id <IRTMPEvent>)event;
+(id)packetWithData:(char *)buffer ofSize:(size_t)size;
-(void)addBuffer:(char *)buffer ofSize:(size_t)size;
+(NSString *)keyByChannelId:(int)channelId;
-(NSString *)keyByChannelId;
-(int)headerSize;
-(int)packetSize;
-(int)pendingSize;
-(void)constructHeader;
-(void)constructHeader:(RTMPHeaderType)type;
-(void)setMessageLength;
-(void)clearHeaderFromData;
-(id)contentRetained;
-(id)contentAutoreleased;
@end
