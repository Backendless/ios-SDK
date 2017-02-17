//
//  Logger.h
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

#import <Foundation/Foundation.h>

@interface Logger : NSObject
+(id)logger:(NSString *)loggerName;
-(void)debug:(NSString *)message;
-(void)info:(NSString *)message;
-(void)trace:(NSString *)message;
-(void)warn:(NSString *)message;
-(void)warn:(NSString *)message exception:(NSException *)exception;
-(void)error:(NSString *)message;
-(void)error:(NSString *)message exception:(NSException *)exception;
-(void)fatal:(NSString *)message;
-(void)fatal:(NSString *)message exception:(NSException *)exception;
@end
