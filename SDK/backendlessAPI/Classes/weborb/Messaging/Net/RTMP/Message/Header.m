//
//  Header.m
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

#import "Header.h"


@implementation Header
@synthesize channelId, size, dataType, streamId, timerBase, timerDelta, timerExt;

-(id)init {	
	if ( (self=[super init]) ) {
		channelId = 0;
		size = 0;
		dataType = 0;
		streamId = 0;
		timerBase = 0;
		timerDelta = 0;
        timerExt = NO;
	}
	
	return self;
}

-(id)initWithHeader:(Header *)header {	
    
    if (!header)
        return [self init];
    
	if ( (self=[super init]) ) {
		channelId = header.channelId;
		size = header.size;
		dataType = header.dataType;
		streamId = header.streamId;
		timerBase = header.timerBase;
		timerDelta = header.timerDelta;
        timerExt = header.timerExt;
	}
	
	return self;
}

+(id)header {
	return [[[Header alloc] init] autorelease];
}

+(id)headerWithHeader:(Header *)header {
	return [[[Header alloc] initWithHeader:header] autorelease];
}

#pragma mark -
#pragma mark Public Methods

-(uint)getTimer {
	return timerBase + timerDelta;
}

-(void)setTimer:(uint)timer {
	timerBase = timer;
	timerDelta = 0;
}
-(BOOL)equals:(Header *)other {
	return (other.channelId == channelId) && (other.size == size) && (other.dataType == dataType) && (other.streamId == streamId) 
        && (other.timerBase == timerBase) && (other.timerDelta == timerDelta) && (other.timerExt == timerExt);
}

-(NSString *)toString {
	return [NSString stringWithFormat:@"Header -> channelId: %d, size: %d, dataType: %d, streamId: %d, timerBase: %d, timerDelta: %d, timerExt: %d", channelId, size, dataType, streamId, timerBase, timerDelta, (int)timerExt];
}

@end
