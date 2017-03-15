//
//  DEBUG.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 18.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "DEBUG.h"

BOOL IS_DEBUG_ACTIVE = NO;

@implementation DebLog

+(void)setIsActive:(BOOL)isActive {
    IS_DEBUG_ACTIVE = isActive;
}

+(BOOL)getIsActive {
    return IS_DEBUG_ACTIVE;
}

+(void)log:(NSString *)format,... {
    if (IS_DEBUG_ACTIVE) {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);  
    }    
}

+(void)log:(BOOL)show text:(NSString *)format,... {
    if (show) {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);  
    }    
}

+(void)logY:(NSString *)format,... {
    va_list args;
    va_start(args, format);
    NSLogv(format, args);
    va_end(args);  
}

+(void)logN:(NSString *)format,... {
    
}

@end
