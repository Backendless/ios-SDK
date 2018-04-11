//
//  Logging.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2015 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "Logging.h"
#import "DEBUG.h"
#import "Responder.h"
#import "Logger.h"
#import "LogBuffer.h"

@interface Logging () {
    NSMutableDictionary *loggers;
}
@end

@implementation Logging

-(id)init {
    if (self = [super init]) {
        loggers = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC Logging"];
    [loggers removeAllObjects];
    [loggers release];
    [super dealloc];
}

-(void)setLogReportingPolicy:(int)numOfMessages time:(int)timeFrequencySec {
    [[LogBuffer sharedInstance] setLogReportingPolicy:numOfMessages time:timeFrequencySec];
}

-(void)setLogResponder:(Responder *)responder {
    [LogBuffer sharedInstance].responder = responder;
}

-(Logger *)getLoggerClass:(Class)clazz {
    return [self getLogger:NSStringFromClass(clazz)];
}

-(Logger *)getLogger:(NSString *)loggerName {
    Logger *logger = loggers[loggerName];
    if (!logger) {
        loggers[loggerName] = logger = [Logger logger:loggerName];
    }    
    return logger;
}

-(void)flush {
    [[LogBuffer sharedInstance] forceFlush];
}

@end

