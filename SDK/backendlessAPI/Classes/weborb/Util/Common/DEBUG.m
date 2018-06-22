//
//  DEBUG.m
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
