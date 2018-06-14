//
//  Header.h
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


@interface Header : NSObject {
	uint	channelId;
	uint	size;
	uint	dataType;
	uint	streamId;
	uint	timerBase;
	uint	timerDelta;
    BOOL    timerExt;
}
@property uint channelId;
@property uint size;
@property uint dataType;
@property uint streamId;
@property uint timerBase;
@property uint timerDelta;
@property BOOL timerExt;

-(id)initWithHeader:(Header *)header;
+(id)header;
+(id)headerWithHeader:(Header *)header;
-(uint)getTimer;
-(void)setTimer:(uint)timer;
-(BOOL)equals:(Header *)other;
-(NSString *)toString;
@end
