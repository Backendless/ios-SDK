//
//  Header.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 16.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
