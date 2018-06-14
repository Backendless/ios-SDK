//
//  IRTMPEvent.h
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
