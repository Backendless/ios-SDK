//
//  CustomService.m
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

#import "CustomService.h"
#import "Backendless.h"
#import "Invoker.h"
#import "CustomServiceAdapter.h"

#define FAULT_NO_SERVICE [Fault  fault:@"Service not found" detail:@"Service not found" faultCode:@"14001"]
#define FAULT_NO_SERVICE_METHOD [Fault fault:@"Service method not found" detail:@"Service method not found" faultCode:@"14002"]

// SERVICE NAME
static NSString *SERVER_CUSTOM_SERVICE_PATH = @"com.backendless.services.servercode.CustomServiceHandler";
// METHOD NAMES
static NSString *METHOD_DISPATCH_SERVICE = @"dispatchService";

@implementation CustomService

// sync methods with fault return (as exception)
-(id)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args {
    if (!serviceName) {
        return [backendless throwFault:FAULT_NO_SERVICE];
    }
    if (!method) {
        return [backendless throwFault:FAULT_NO_SERVICE_METHOD];
    }
    NSArray *_args = @[serviceName, method, args?args:@[]];
    return [invoker invokeSync:SERVER_CUSTOM_SERVICE_PATH method:METHOD_DISPATCH_SERVICE args:_args responseAdapter:[CustomServiceAdapter new]];
}

// async methods with responder
-(void)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args responder:(id <IResponder>)responder {
    if (!serviceName) {
        return [responder errorHandler:FAULT_NO_SERVICE];
    }
    if (!method) {
        return [responder errorHandler:FAULT_NO_SERVICE_METHOD];
    }
    NSArray *_args = @[serviceName, method, args?args:@[]];
    [invoker invokeAsync:SERVER_CUSTOM_SERVICE_PATH method:METHOD_DISPATCH_SERVICE args:_args responder:responder responseAdapter:[CustomServiceAdapter new]];
}

// async methods with block-based callbacks
-(void)invoke:(NSString *)serviceName method:(NSString *)method args:(NSArray *)args response:(void(^)(id))responseBlock error:(void(^)(Fault *fault))errorBlock {
    [self invoke:serviceName method:method args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
