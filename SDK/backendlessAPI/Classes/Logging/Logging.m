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
#import "Types.h"
#import "Backendless.h"
#import "Invoker.h"

#define FAULT_NO_SERVICE_OPTIONS [Fault fault:@"Service options is not valid" faultCode:@"0000"]

// SERVICE NAME
static NSString *SERVER_LOG_SERVICE_PATH = @"com.backendless.services.logging.LogService";
// METHOD NAMES
static NSString *METHOD_LOG = @"log";
static NSString *METHOD_BATCHLOG = @"batchLog";

@interface LogMessage : NSObject
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *exception;
@end

@implementation LogMessage
@end

@interface LogBatch : NSObject
@property (strong, nonatomic) NSString *logLevel;
@property (strong, nonatomic) NSString *logger;
@property (strong, nonatomic) NSMutableSet *messages; // List<LogMessage>
@end

@implementation LogBatch
@end


@interface Logging () {
    
    NSMutableSet *_logBatchList;
    
    int _numOfMessages;
    int _timeFrequencyMS;
}

@end

@implementation Logging

-(id)init {
    
    if ( (self=[super init]) ) {
        
        _logBatchList = [NSMutableSet new];
        
        _numOfMessages = 1;
        _timeFrequencyMS = 0;
        
#if 0 // ????
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.logging.LogMessage" mapped:[LogMessage class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.logging.LogBatch" mapped:[LogBatch class]];
#endif
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC Logging"];
    
    [_logBatchList release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)setLogReportingPolicy:(int)numOfMessages time:(int)timeFrequencyMS {
    _numOfMessages = numOfMessages;
    _timeFrequencyMS = timeFrequencyMS;
}

-(Logger *)getLoggerClass:(Class)clazz {
    return [Logger logger:NSStringFromClass(clazz)];
}

-(Logger *)getLogger:(NSString *)loggerName {
    return [Logger logger:loggerName];
}

#if 0
log( String appId, String version, String logLevel, String logger, String message, String exception )
batchLog( String appId, String version, List<LogBatch> logs )
#endif

-(id)log:(NSString *)logger level:(NSString *)level message:(NSString *)message exception:(NSString *)exception {
    
    if (!logger || !message)
        return [backendless throwFault:FAULT_NO_SERVICE_OPTIONS];
    
    if (_numOfMessages > 1) {
        
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, level, logger, message, exception];
    return [invoker invokeSync:SERVER_LOG_SERVICE_PATH method:METHOD_LOG args:args];
}

#pragma mark -
#pragma mark Private Methods

-(id)throwBatchLog {
    
    if (!_logBatchList || !_logBatchList.count)
        return nil;
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _logBatchList];
    id result = [invoker invokeSync:SERVER_LOG_SERVICE_PATH method:METHOD_BATCHLOG args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    [_logBatchList removeAllObjects];
    
    return result;
}

@end

