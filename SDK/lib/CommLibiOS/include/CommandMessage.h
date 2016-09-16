//
//  CommandMessage.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 3/22/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V3Message.h"

@interface CommandMessage : V3Message {
    NSString    *operation;
}
@property (nonatomic, assign) NSString *operation;

+(id)command:(NSString *)_operation;
@end
