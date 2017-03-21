//
//  V3Message.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BodyHolder.h"

@class Request;

@interface V3Message : NSObject {
    // serialized
    double      timestamp;
    BodyHolder  *body;
    int         timeToLive;
    NSString    *destination;
    NSString    *messageId;
    id          clientId;
    NSMutableDictionary *headers;
    NSString    *correlationId;
    BOOL        isError;    
}
@property double timestamp;
@property (nonatomic, assign) BodyHolder *body;
@property int timeToLive;
@property (nonatomic, assign) NSString *destination;
@property (nonatomic, assign) NSString *messageId;
@property (nonatomic, assign) id clientId;
@property (nonatomic, assign) NSMutableDictionary *headers;
@property (nonatomic, assign) NSString *correlationId;
@property BOOL isError;

-(V3Message *)execute:(Request *)message context:(NSDictionary *)context;
@end
