//
//  IEvent.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "EventType.h"
#import "IEventListener.h"

@protocol IEvent <NSObject>
@optional
-(EventType)getType;
-(id)getObject;
-(BOOL)hasSource;
-(id <IEventListener>)getSource;
@end
