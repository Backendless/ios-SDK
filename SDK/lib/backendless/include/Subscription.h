//
//  Subscription.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 3/22/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

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
