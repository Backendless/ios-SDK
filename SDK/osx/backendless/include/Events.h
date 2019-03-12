//
//  Events.h
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
#import "ExecutionType.h"

@protocol IResponder;
@class Fault;

@interface Events : NSObject

// sync methods with fault return (as exception)
-(NSDictionary *)dispatch:(NSString *)name args:(NSDictionary *)eventArgs;
-(NSDictionary *)dispatch:(NSString* )name args:(NSDictionary *)eventArgs executionType:(ExecutionType)executionType;

// async methods with responder
-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs responder:(id <IResponder>)responder;
-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs executionType:(ExecutionType)executionType responder:(id<IResponder>)responder;

// async methods with block-based callbacks
-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs response:(void(^)(NSDictionary *data))responseBlock error:(void(^)(Fault *fault))errorBlock;
-(void)dispatch:(NSString *)name args:(NSDictionary *)eventArgs executionType:(ExecutionType)executionType response:(void(^)(NSDictionary *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
