//
//  AudioData.h
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
#import "BaseEvent.h"
#import "IStreamPacket.h"
#import "BinaryStream.h"

@protocol IAudioStreamCodec;

@interface AudioData : BaseEvent <IStreamPacket> {
    BinaryStream            *data;    
    id <IAudioStreamCodec>  codec;
}
@property (nonatomic, retain, getter = getData, setter = setData:) BinaryStream *data;
@property (nonatomic, retain, getter = getCodec, setter = setCodec:) id <IAudioStreamCodec> codec;

-(id)initWithBinaryStream:(BinaryStream *)stream;
-(id)initWithCodec:(id <IAudioStreamCodec>)audioCodec;
-(id)initWithBinaryStream:(BinaryStream *)stream audioCodec:(id <IAudioStreamCodec>)audioCodec;
@end
