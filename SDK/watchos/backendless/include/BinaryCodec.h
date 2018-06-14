//
//  BinaryCodec.h
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

#import <Foundation/Foundation.h>

#define DEFAULT_MAX_SIZE 65535

@interface BEBase64 : NSObject
+(NSString *)encode:(const uint8_t *)input length:(NSInteger)length;
+(NSString *)encode:(NSData *)rawBytes;
+(NSData *)decode:(const char *)string length:(NSInteger)inputLength;
+(NSData *)decode:(NSString *)string;
//
+(NSArray *)encodeToStringArray:(NSData *)rawBytes limit:(size_t)limit;
+(NSArray *)encodeToStringArray:(NSData *)rawBytes;
+(NSData *)decodeFromStringArray:(NSArray *)stringArray;
@end
