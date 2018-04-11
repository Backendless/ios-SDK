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

#define FAULT_WRONG_POLICY [Fault fault:@"Invalid or missing fields for Policy" detail:@"Invalid or missing fields for Policy" faultCode:@"21000"]

static NSString *SERVER_LOG_SERVICE_PATH = @"com.backendless.services.logging.LogService";
static NSString *METHOD_LOG = @"log";
static NSString *METHOD_BATCHLOG = @"batchLog";

@interface LogMessage : NSObject

@property (strong, nonatomic) NSString *logger;
@property (strong, nonatomic) NSString *level;
@property (strong, nonatomic) NSDate *timestamp;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *exception;

@end

@implementation LogMessage

+(LogMessage *)logMessage:(NSString *)logger level:(NSString *)level time:(NSDate *)timestamp message:(NSString *)message exception:(NSString *)exception {
    LogMessage *instance = [LogMessage new];
    instance.logger = logger;
    instance.level = level;
    instance.timestamp = timestamp;
    instance.message = message;
    instance.exception = exception;
    return instance;
}

@end

@interface LogBuffer () {
    NSMutableArray *_logMessages;
    int _numOfMessages;
    int _timeFrequency;
}
@end

@implementation LogBuffer

+(instancetype)sharedInstance {
    static LogBuffer *sharedLogBuffer;
    @synchronized(self) {
        if (!sharedLogBuffer)
            sharedLogBuffer = [LogBuffer new];
    }
    return sharedLogBuffer;
}

-(instancetype)init {
    if (self = [super init]) {
        self.responder = [Responder responder:self selResponseHandler:@selector(getResponse:) selErrorHandler:@selector(getError:)];
        _logMessages = [NSMutableArray new];
        _numOfMessages = 100;
        _timeFrequency = 60 * 5; // 5 minutes
        [self flushMessages];
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC LogBuffer"];
    [_logMessages removeAllObjects];
    [_logMessages release];
    [_responder release];
    [super dealloc];
}

-(id)setLogReportingPolicy:(int)messagesNum time:(int)timeFrequencySec {
    if (messagesNum <= 0 && timeFrequencySec <= 0)
        return [backendless throwFault:FAULT_WRONG_POLICY];
    [DebLog log:@"LogBuffer -> setLogReportingPolicy: messagesNum = %d, timeFrequencyMS = %d", messagesNum, timeFrequencySec];
    _numOfMessages = messagesNum;
    _timeFrequency = timeFrequencySec;
    [self flushMessages];
    return nil;
}

-(void)enqueue:(NSString *)logger level:(NSString *)level message:(NSString *)message exception:(NSString *)exception {
    [DebLog logN:@"LogBuffer -> enqueue: _numOfMessages = %d, logger = '%@', level = '%@', message = '%@', exeption = '%@'", _numOfMessages, logger, level, message, exception];
    if (_numOfMessages == 1) {
        [self reportSingleLogMessage:logger level:level message:message exception:exception];
        return;
    }
    LogMessage *logMessage = [LogMessage logMessage:logger level:level time:[NSDate date] message:message exception:exception];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_logMessages addObject:logMessage];
        [DebLog logN:@"LogBuffer -> enqueue: _numOfMessages = %d, _logMessages.count= %d", _numOfMessages, _logMessages.count];
        if (_numOfMessages > 1 && _logMessages.count >= _numOfMessages) {
            [self flush];
        }
    });
}

-(void)forceFlush {    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self flush];
    });
}

-(void)reportSingleLogMessage:(NSString *)logger level:(NSString *)level message:(NSString *)message exception:(NSString *)exception {
    if (!logger || !level || !message)
        return;
    [DebLog log:@"LogBuffer -> reportSingleLogMessage: _numOfMessages = %d, logger = '%@', level = '%@', message = '%@', exeption = '%@'", _numOfMessages, logger, level, message, exception];
    NSArray *args = @[level, logger, message, exception?exception:[NSNull null]];
    [invoker invokeAsync:SERVER_LOG_SERVICE_PATH method:METHOD_LOG args:args responder:_responder];
}

-(void)reportBatch:(NSArray *)batch {
    if (!batch || !batch.count)
        return;
    [DebLog log:@"LogBuffer -> reportBatch: %@", batch];
    NSArray *args = @[batch];
    [invoker invokeAsync:SERVER_LOG_SERVICE_PATH method:METHOD_BATCHLOG args:args responder:_responder];
}

-(void)flush {
    if (!_logMessages.count)
        return;
    [self reportBatch:_logMessages];
    [_logMessages removeAllObjects];
}

-(void)flushMessages {
    [self flush];
    if (_numOfMessages == 1 || _timeFrequency <= 0)
        return;
    dispatch_time_t interval = dispatch_time(DISPATCH_TIME_NOW, 1ull*NSEC_PER_SEC*_timeFrequency);
    dispatch_after(interval, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self flushMessages];
    });
}

-(id)getResponse:(id)response {
    [DebLog log:@"LogBuffer -> getResponse: %@", response];
    return response;
}

-(id)getError:(id)error {
    [DebLog log:@"LogBuffer -> getError: %@", error];
    return error;
}

@end
