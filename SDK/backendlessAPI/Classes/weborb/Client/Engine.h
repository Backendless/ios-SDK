//
//  Engine.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V3Message, AsyncMessage, SubscribedHandler, IdInfo;
@protocol IResponder;

@interface Engine : NSObject {
    // event
    SubscribedHandler   *subscribedHandler;
    // indentification info
    IdInfo      *idInfo;
    //
    NSString    *gatewayUrl;
    NSString    *subTopic;
    NSString    *selector;
	id          _responder;
    
    // headers (optional)
    NSMutableDictionary *requestHeaders;
    NSMutableDictionary *httpHeaders;
}
@property (nonatomic, retain) SubscribedHandler *subscribedHandler;
@property (nonatomic, assign) IdInfo *idInfo;
@property (nonatomic, retain) NSMutableDictionary *requestHeaders;
@property (nonatomic, retain) NSMutableDictionary *httpHeaders;
@property BOOL networkActivityIndicatorOn;

-(id)initWithUrl:(NSString *)url;
-(id)initWithUrl:(NSString *)url info:(IdInfo *)info;
+(id)create:(NSString *)url;
+(id)create:(NSString *)url info:(IdInfo *)info;

// sync
-(id)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args;
-(id)sendRequest:(V3Message *)v3Msg;
// async
-(void)invoke:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder;
-(void)sendRequest:(V3Message *)v3Msg responder:(id <IResponder>)responder;
-(void)onSubscribed:(NSString *)_subTopic selector:(NSString *)_selector responder:(id <IResponder>)responder;
-(void)onUnsubscribed;
-(void)stop;
// "protected" (for inside usage - NEVER UDE IT DIRECTLY)
-(void)receivedMessage:(AsyncMessage *)message;
-(V3Message *)createMessageForInvocation:(NSString *)className method:(NSString *)methodName args:(NSArray *)args;
-(V3Message *)createMessageForInvocation:(NSString *)methodName args:(NSArray *)args;
@end
