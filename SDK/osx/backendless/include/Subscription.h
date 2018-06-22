//
//  Subscription.h
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

#define DSSELECTOR @"DSSelector"
#define DSSUBTOPIC @"DSSubtopic"
#define DSID @"DSId"

@class Engine, CommandMessage, IdInfo;
@protocol IResponder;

@interface Subscription : NSObject {
    
    NSString    *subTopic;
    NSString    *selector;
    Engine      *engine;
    
    id          responder;
    BOOL        isSubscribed;
    
    IdInfo      *idInfo;
    id          dsIdLock;
}
@property (readonly) BOOL isSubscribed;

-(id)initWithSubTopic:(NSString *)_subTopic selector:(NSString *)_selector engine:(Engine *)_engine;
+(NSString *)getIdBySubTopicSelector:(NSString *)_subTopic selector:(NSString *)_selector;
-(NSString *)getId;
+(CommandMessage *)getCommandMessage:(NSString *)operation subTopic:(NSString *)_subTopic selector:(NSString *)_selector idInfo:(IdInfo *)_idInfo;
-(CommandMessage *)getCommandMessage:(NSString *)operation;
-(void)subscribe:(id <IResponder>)_responder;
-(void)unsubscribe:(id <IResponder>)_responder;
@end
