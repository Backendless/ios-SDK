//
//  IStreamPacket.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 8/12/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BinaryStream;

@protocol IStreamPacket <NSObject>
/**
 * Type of this packet. This is one of the <code>TYPE_</code> constants.
 * 
 * @return the type
 */
-(int)getDataType;

/**
 * Timestamp of this packet.
 * 
 * @return the timestamp in milliseconds
 */
-(int)getTimestamp;

/**
 * Packet contents.
 * 
 * @return the contents
 */
-(BinaryStream *)getData;

@end
