//
//  IRTMPEvent.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IEvent.h"
#import "IEventListener.h"
#import "Header.h"

@protocol IRTMPEvent <IEvent>

-(uint)getDataType; 

@optional
/**
 * Setter for source
 *
 * @param source Source
 */
-(void)setSource:(id <IEventListener>)source;

/**
 * Getter for source type
 *
 * @return  Source type
 */
-(uint)getSourceType;

/**
 * Setter for source type
 *
 * @param sourceType 
 */
-(void)setSourceType:(uint)sourceType;

/**
 * Getter for header
 *
 * @return  RTMP packet header
 */
-(Header *)getHeader;

/**
 * Setter for header
 *
 * @param header RTMP packet header
 */
-(void)setHeader:(Header *)header;

/**
 * Getter for timestamp
 *
 * @return  Event timestamp
 */
-(int)getTimestamp;

/**
 * Setter for timestamp
 *
 * @param timestamp  New event timestamp
 */
-(void)setTimestamp:(int)timestamp;

@end
