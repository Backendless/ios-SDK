//
//  V3Message.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
