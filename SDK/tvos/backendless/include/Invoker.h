//
//  Invoker.h
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
#import "IAdaptingType.h"
#import "IResponseAdapter.h"
#import "Responder.h"

#define invoker [Invoker sharedInstance]

@protocol IResponder;

@interface Invoker : NSObject

@property BOOL throwException;

+(Invoker *)sharedInstance;

-(void)setup;
-(void)setRequestHeader:(NSString *)header value:(id)value;
-(void)removeRequestHeader:(NSString *)header;
-(void)setNetworkActivityIndicatorOn:(BOOL)value;
-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args;
-(id)invokeSync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responseAdapter:(id<IResponseAdapter>)responseAdapter;
-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder;
-(void)invokeAsync:(NSString *)className method:(NSString *)methodName args:(NSArray *)args responder:(id <IResponder>)responder responseAdapter:(id<IResponseAdapter>)responseAdapter;

@end
