//
//  IEventListener.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@protocol IEvent;

@protocol IEventListener <NSObject>
-(void)notifyEvent:(id <IEvent>)evt;
@end
