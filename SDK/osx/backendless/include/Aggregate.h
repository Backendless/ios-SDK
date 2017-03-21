//
//  Aggregate.h
//  RTMPStream
//
//  Created by Dmytro Krasikov on 10/7/11.
//  Created by Vyacheslav Vdovichenko on 4/25/12.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"

@class BinaryReader;

@interface Aggregate : BaseEvent {
    BinaryReader * data;
}

-(id)initWithStream:(char *)stream andSize:(size_t)length;
-(NSArray*)getEvents;
@end
