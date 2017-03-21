//
//  AckMessage.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V3Message.h"


@interface AckMessage : V3Message
-(id)initWithObject:(id)obj correlationId:(NSString *)corrID clientId:(NSString *)clId;
-(id)initWithObject:(id)obj correlationId:(NSString *)corrID clientId:(NSString *)clId headers:(NSDictionary *)headersDict;
-(V3Message *)execute:(Request *)message;
@end
