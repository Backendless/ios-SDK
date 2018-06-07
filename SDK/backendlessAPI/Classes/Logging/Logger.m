//
//  Logger.m
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

#import "Logger.h"
#import "DEBUG.h"
#import "LogBuffer.h"

@interface Logger ()

@property (strong, nonatomic) NSString *name;

@end

@implementation Logger

-(id)init {
    if (self = [super init]) {
        _name = nil;
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC Logger"];
    [_name release];    
    [super dealloc];
}

+(instancetype)logger:(NSString *)loggerName {
    Logger *logger = [Logger new];
    logger.name = loggerName;
    return logger;
}

-(void)debug:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"DEBUG" message:message exception:nil];
}

-(void)info:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"INFO" message:message exception:nil];
}

-(void)trace:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"TRACE" message:message exception:nil];
}

-(void)warn:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"WARN" message:message exception:nil];
}

-(void)warn:(NSString *)message exception:(NSException *)exception {
    [[LogBuffer sharedInstance] enqueue:_name level:@"WARN" message:message exception:exception.reason];
}

-(void)error:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"ERROR" message:message exception:nil];
}

-(void)error:(NSString *)message exception:(NSException *)exception {
    [[LogBuffer sharedInstance] enqueue:_name level:@"ERROR" message:message exception:exception.reason];
}

-(void)fatal:(NSString *)message {
    [[LogBuffer sharedInstance] enqueue:_name level:@"FATAL" message:message exception:nil];
}

-(void)fatal:(NSString *)message exception:(NSException *)exception {
    [[LogBuffer sharedInstance] enqueue:_name level:@"FATAL" message:message exception:exception.reason];
}

@end
