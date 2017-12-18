//
//  BackendlessPushHelper.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
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
#if TARGET_OS_IOS || TARGET_OS_SIMULATOR
#import <UserNotifications/UserNotifications.h>
#endif

@interface BackendlessPushHelper : NSObject

#if TARGET_OS_IOS || TARGET_OS_SIMULATOR
+(void)processMutableContent:(UNNotificationRequest *_Nonnull)request withContentHandler:(void (^_Nonnull)(UNNotificationContent *_Nonnull))contentHandler NS_AVAILABLE_IOS(10_0);
#endif

@end
