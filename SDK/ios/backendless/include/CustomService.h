//
//  CustomService.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
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

@protocol IResponder;
@class Fault;

@interface CustomService : NSObject
// sync methods with fault return (as exception)
-(id)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args;
// async methods with responder
-(void)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args responder:(id<IResponder>)responder;
// async methods with block-based callbacks
-(void)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args response:(void(^)(id))responseBlock error:(void(^)(Fault *fault))errorBlock;
@end
