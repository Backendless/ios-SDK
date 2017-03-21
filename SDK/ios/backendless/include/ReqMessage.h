//
//  ReqMessage.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V3Message.h"


@interface ReqMessage : V3Message {
    // serialized
    NSString    *operation;
    NSString    *source;
    NSString    *messageRefType;
}
@property (nonatomic, assign) NSString *operation;
@property (nonatomic, assign) NSString *source;
@property (nonatomic, assign) NSString *messageRefType;

@end
