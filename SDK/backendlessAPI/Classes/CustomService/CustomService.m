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

#define FAULT_NO_SERVICE_OPTIONS [Fault fault:@"Service options is not valid" faultCode:@"7900"]

// SERVICE NAME
static NSString *SERVER_CUSTOM_SERVICE_PATH = @"com.backendless.services.servercode.CustomServiceHandler";
// METHOD NAMES
static NSString *METHOD_DISPATCH_SERVICE = @"dispatchService";

@implementation CustomService

// sync methods with fault return (as exception)
-(id)invoke:(NSString *)serviceName serviceVersion:(NSString *)serviceVersion method:(NSString *)method args:(NSArray *)args {
    
    if (!serviceName || !serviceVersion || !method)
        return [backendless throwFault:FAULT_NO_SERVICE_OPTIONS];
    
    NSArray *_args = @[backendless.appID, backendless.versionNum, serviceName, serviceVersion, method, args?args:@[]];
    return [invoker invokeSync:SERVER_CUSTOM_SERVICE_PATH method:METHOD_DISPATCH_SERVICE args:_args];
}

// sync methods with fault option

#if OLD_ASYNC_WITH_FAULT

-(id)invoke:(NSString *)serviceName serviceVersion:(NSString *)serviceVersion method:(NSString *)method args:(NSArray *)args fault:(Fault **)fault {
    
    id result = [self invoke:serviceName serviceVersion:serviceVersion method:method args:args];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
#else

#if 0 // wrapper for work without exception

id result = nil;
@try {
}
@catch (Fault *fault) {
    result = fault;
}
@finally {
    if ([result isKindOfClass:Fault.class]) {
        if (fault)(*fault) = result;
        return nil;
    }
    return result;
}

#endif

-(id)invoke:(NSString *)serviceName serviceVersion:(NSString *)serviceVersion method:(NSString *)method args:(NSArray *)args fault:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self invoke:serviceName serviceVersion:serviceVersion method:method args:args];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}
#endif

// async methods with responder
-(void)invoke:(NSString *)serviceName serviceVersion:(NSString *)serviceVersion method:(NSString *)method args:(NSArray *)args responder:(id <IResponder>)responder {
    
    if (!serviceName || !serviceVersion || !method)
        return [responder errorHandler:FAULT_NO_SERVICE_OPTIONS];
    
    NSArray *_args = @[backendless.appID, backendless.versionNum, serviceName, serviceVersion, method, args?args:@[]];
    [invoker invokeAsync:SERVER_CUSTOM_SERVICE_PATH method:METHOD_DISPATCH_SERVICE args:_args responder:responder];
}

// async methods with block-based callbacks
-(void)invoke:(NSString *)serviceName serviceVersion:(NSString *)serviceVersion method:(NSString *)method args:(NSArray *)args response:(void(^)(id))responseBlock error:(void(^)(Fault *fault))errorBlock {
    [self invoke:serviceName serviceVersion:serviceVersion method:method args:args responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

@end
