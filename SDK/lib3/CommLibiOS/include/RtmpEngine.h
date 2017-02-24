//
//  RtmpEngine.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 2/15/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Engine.h"

@class RTMPClient;

@interface RtmpEngine : Engine {
    
    NSString    *_host;
	int			_port;
    NSString    *_app;
    NSString    *protocol;
    
    // rtmp
    RTMPClient  *client;
}
@property (nonatomic, assign, readonly) RTMPClient *client;
@end
