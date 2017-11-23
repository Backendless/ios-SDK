//
//  PublishMessageInfo.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
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

@interface PublishMessageInfo : NSObject {
    
    NSString *message;
    NSString *publisherId;
    NSString *subtopic;
    NSNumber *pushBroadcast;
    NSArray  *pushSinglecast;
    NSMutableDictionary *headers;
}
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *publisherId;
@property (strong, nonatomic) NSString *subtopic;
@property (strong, nonatomic) NSNumber *pushBroadcast;
@property (strong, nonatomic) NSArray  *pushSinglecast;
@property (strong, nonatomic) NSMutableDictionary *headers;

-(id)initWithMessage:(NSString *)_message;
-(void)addHeaders:(NSDictionary *)_headers;
@end
