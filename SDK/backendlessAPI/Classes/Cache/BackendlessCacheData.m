//
//  BackendlessCacheData.m
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

#import "BackendlessCacheData.h"
#import "AMFSerializer.h"

@interface BackendlessCacheData()

-(NSString *)createFilePath;

@end

@implementation BackendlessCacheData

-(id)init {
    if (self = [super init]) {
        _priority = [[NSNumber alloc] initWithInt:1];
        _file = nil;
    }
    return self;
}

-(id)initWithCache:(BackendlessCacheData *)cache {
    if (self = [super init]) {
        _file = [cache.file copy];
        _data = [cache.data retain];
        _timeToLive = [[NSNumber alloc] initWithInt:cache.timeToLive.intValue];
        _priority = [[NSNumber alloc] initWithInt:cache.priority.intValue];
    }
    return self;
}

-(void)dealloc {
    [_file release];
    [_priority release];
    [_timeToLive release];
    [_data release];
    [super dealloc];
}

-(void)increasePriority {
    NSInteger priority = _priority.integerValue;
    priority++;
    _priority = [[NSNumber alloc] initWithInteger:priority];
}

-(void)decreasePriority {
    NSInteger priority = _priority.integerValue;
    priority--;
    _priority = [[NSNumber alloc] initWithInteger:priority];
}

-(NSInteger)valPriority {
    return _priority.integerValue;
}

-(void)saveOnDiscCompletion:(BackendlessCacheDataSaveCompletion)block {
    _file = [[self createFilePath] retain];
    dispatch_queue_t queue = dispatch_queue_create("BackendlessSaveOnDiscCompletion", nil);
    dispatch_async(queue, ^{
        @autoreleasepool {
            BinaryStream *stream = [AMFSerializer serializeToBytes:self.data];
            NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
            BOOL result = [data writeToFile:_file atomically:YES];
            if (!result) {
                _file = nil;
            }
            block(result);
            dispatch_release(queue);
        }
    });
}
-(NSString *)createFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/%i.cache", (int)[[NSDate date] timeIntervalSince1970]];
    return filePath;
}

-(id)dataFromDisc {
    if ([_file length]>0) {
        NSData *data = [NSData dataWithContentsOfFile:_file];
        BinaryStream *stream = [BinaryStream streamWithStream:(char *)[data bytes] andSize:data.length];
        self.data = [AMFSerializer deserializeFromBytes:stream];
    }
    return _data;
}

-(void)remove {
    if (_file.length > 0) {
        [[NSFileManager defaultManager] removeItemAtPath:_file error:nil];
    }
}

-(void)removeFromDisc {
    if (_file.length > 0) {
        if (!_data) {
            [self dataFromDisc];
        }
        [[NSFileManager defaultManager] removeItemAtPath:_file error:nil];
        [_file release];
        _file = nil;
    }
}

@end
