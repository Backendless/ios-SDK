//
//  IEventDispatcher.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IEvent.h"

@protocol IEventDispatcher <NSObject>
-(void)dispatchEvent:(id <IEvent>)evt;
@end
