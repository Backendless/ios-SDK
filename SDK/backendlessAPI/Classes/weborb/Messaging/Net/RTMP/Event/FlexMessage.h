//
//  FlexMessage.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 2/16/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "Invoke.h"

@interface FlexMessage : Invoke {
    int     msgId;
    int     msgLength;
    long    msgTime;
    int     streamId;
    int     version;
    id      command;
}
@property int msgId;
@property int msgLength;
@property long msgTime;
@property int streamId;
@property int version;
@property (nonatomic, assign) id command;
@end
