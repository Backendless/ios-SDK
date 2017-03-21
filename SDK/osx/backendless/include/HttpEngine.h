//
//  HttpEngine.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Engine.h"

@interface HttpEngine : Engine {
    // async responders
	NSMutableArray  *asyncResponses;
    BOOL            isPolling;
}
@end
