//
//  BaseRTMPProtocolEncoder.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebORBSerializer.h"
#import "BinaryStream.h"
#import "BaseEvent.h"


@interface BaseRTMPProtocolEncoder : NSObject {
	WebORBSerializer	*serializer;
	id <IRTMPEvent>		event;
	
}

+(id)coder;
-(void)setSerializer:(WebORBSerializer *)coder;
-(BinaryStream *)encodeMessage:(id <IRTMPEvent>)message;
@end
