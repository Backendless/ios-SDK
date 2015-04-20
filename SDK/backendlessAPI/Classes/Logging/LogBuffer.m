//
//  LogBuffer.m
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

#import "LogBuffer.h"
#import "Backendless.h"
#import "Invoker.h"

#define FAULT_WRONG_FREQUENCY [Fault fault:@"The time frequency argument must be greater than zero"]

// SERVICE NAME
static NSString *SERVER_LOG_SERVICE_PATH = @"com.backendless.services.logging.LogService";
// METHOD NAMES
static NSString *METHOD_LOG = @"log";
static NSString *METHOD_BATCHLOG = @"batchLog";

@interface LogMessage : NSObject
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *exception;
+(LogMessage *)logMessage:(NSDate *)timestamp message:(NSString *)message exception:(NSString *)exception;
@end

@implementation LogMessage
+(LogMessage *)logMessage:(NSDate *)timestamp message:(NSString *)message exception:(NSString *)exception {
    LogMessage *instance = [LogMessage new];
    instance.timestamp = timestamp;
    instance.message = message;
    instance.exception = exception;
    return instance;
}
@end

@interface LogBatch : NSObject
@property (strong, nonatomic) NSString *logLevel;
@property (strong, nonatomic) NSString *logger;
@property (strong, nonatomic) NSMutableArray *messages; // List<LogMessage>
@end

@implementation LogBatch
@end


@interface LogBuffer () {
    NSMutableDictionary *logBatches;
    int numOfMessages;
    int timeFrequency;
    int messageCount;
}
@end

@implementation LogBuffer

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(LogBuffer *)sharedInstance {
    static LogBuffer *sharedLogBuffer;
    @synchronized(self)
    {
        if (!sharedLogBuffer)
            sharedLogBuffer = [LogBuffer new];
    }
    return sharedLogBuffer;
}

-(id)init {
    if ( (self=[super init]) ) {
        
        _responder = nil;
        logBatches = [NSMutableDictionary new];
        numOfMessages = 100;
        timeFrequency = 1000*60*5; // 5 minutes
        messageCount = 0;
        
        [self flushMessages];
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC LogBuffer"];
    
    messageCount = 0;
    
    [logBatches removeAllObjects];
    [logBatches release];
    
    [_responder release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(id)setLogReportingPolicy:(int)messagesNum time:(int)timeFrequencyMS {
    
    if (numOfMessages != 1 && timeFrequency <= 0)
        return [backendless throwFault:FAULT_WRONG_FREQUENCY];
    
    numOfMessages = messagesNum;
    timeFrequency = timeFrequencyMS;
    
    [self flushMessages];
    
    return nil;
}

-(void)enqueue:(NSString *)logger level:(NSString *)level message:(NSString *)message exception:(NSString *)exception {
    
    if (numOfMessages == 1) {
        [self reportSingleLogMessage:logger level:level message:message exception:exception];
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *logLevels = logBatches[logger];
        if (!logLevels) {
            logBatches[logger] = logLevels = [NSMutableDictionary dictionary];
        }
        
        NSMutableArray *messages = logLevels[level];
        if (!messages) {
            logLevels[level] = messages = [NSMutableArray array];
        }
        
        [messages addObject:[LogMessage logMessage:[NSDate date] message:message exception:exception]];
        if (++messageCount == numOfMessages) {
            [self flush];
        }
    });
}

-(void)forceFlush {    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self flush];
    });
}

#pragma mark -
#pragma mark Private Methods

-(void)reportSingleLogMessage:(NSString *)logger level:(NSString *)level message:(NSString *)message exception:(NSString *)exception {
     
    NSArray *args = @[backendless.appID, backendless.versionNum, level, logger, message, exception?exception:[NSNull null]];
    [invoker invokeAsync:SERVER_LOG_SERVICE_PATH method:METHOD_LOG args:args responder:_responder];
}

-(void)reportBatch:(NSArray *)batch {
    
    if (!batch || !batch.count)
        return;
    
    NSArray *args = @[backendless.appID, backendless.versionNum, batch];
    [invoker invokeAsync:SERVER_LOG_SERVICE_PATH method:METHOD_BATCHLOG args:args responder:_responder];
}

-(void)flush {
    
    if (!messageCount)
        return;
    
    NSMutableArray *allMessages = [NSMutableArray array];
    
    NSArray *batchKeys = [logBatches allKeys];
    for (NSString *logger in batchKeys) {
        
        NSDictionary *logLevels = logBatches[logger];
        NSArray *levelKeys = [logLevels allKeys];
        for (NSString *logLevel in levelKeys) {
            
            LogBatch *logBatch = [LogBatch new];
            logBatch.logger = logger;
            logBatch.logLevel = logLevel;
            logBatch.messages = logLevels[logLevel];
            [allMessages addObject:logBatch];
       }
    }
    
    [logBatches removeAllObjects];
    messageCount = 0;
    
    [self reportBatch:allMessages];
}

-(void)flushMessages {
    
    [self flush];
    
    if (numOfMessages <= 1 || timeFrequency <= 0)
        return;
    
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_MSEC*timeFrequency);
    dispatch_after(interval, dispatch_get_main_queue(), ^{
        [self flushMessages];
    });
}

@end
