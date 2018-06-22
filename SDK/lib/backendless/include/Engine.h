//
//  Engine.h
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
