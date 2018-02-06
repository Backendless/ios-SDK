//
//  BackendlessPushHelper.m
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

#import "BackendlessPushHelper.h"

@implementation BackendlessPushHelper

+(BackendlessPushHelper *)sharedInstance {
    static BackendlessPushHelper *sharedBackendlessPushHelper;
    if (!sharedBackendlessPushHelper) {
        @synchronized(self) {
            sharedBackendlessPushHelper = [BackendlessPushHelper new];
        }
    }
    return sharedBackendlessPushHelper;
}

#if TARGET_OS_IOS || TARGET_OS_SIMULATOR
-(void)processMutableContent:(UNNotificationRequest *_Nonnull)request withContentHandler:(void(^_Nonnull)(UNNotificationContent *_Nonnull))contentHandler NS_AVAILABLE_IOS(10_0) {
    UNMutableNotificationContent *bestAttemptContent = [request.content mutableCopy];
    if ([request.content.userInfo valueForKey:@"attachment-url"]) {
        NSString *urlString = [request.content.userInfo valueForKey:@"attachment-url"];
        NSURL *fileUrl = [NSURL URLWithString:urlString];
        [[[NSURLSession sharedSession] downloadTaskWithURL:fileUrl
                                         completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                             if (location) {
                                                 NSString *tmpDirectory = NSTemporaryDirectory();
                                                 NSString *tmpFile = [[@"file://" stringByAppendingString:tmpDirectory] stringByAppendingString:fileUrl.lastPathComponent];
                                                 NSURL *tmpUrl = [NSURL URLWithString:tmpFile];
                                                 BOOL success = [[NSFileManager defaultManager] moveItemAtURL:location toURL:tmpUrl error:nil];
                                                 UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"" URL:tmpUrl options:nil error:nil];
                                                 if (attachment) {
                                                     bestAttemptContent.attachments = @[attachment];
                                                 }
                                             }
                                             contentHandler(bestAttemptContent);
                                         }] resume];
    }
    else {
        contentHandler(bestAttemptContent);
    }
}

-(UNNotificationRequest *_Nonnull)requestWithIncrementedBadgeBy:(NSNumber *_Nonnull)value fromRequest:(UNNotificationRequest *_Nonnull)request {
    NSNumber *badge = request.content.badge;
    UNMutableNotificationContent *content = [request.content mutableCopy];
    if (content.badge && value) {
        content.badge = [NSNumber numberWithInteger:([badge integerValue] + [value integerValue])];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        return [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
    }
    return request;
}

-(UNNotificationRequest *_Nonnull)requestWithDecrementedBadgeBy:(NSNumber *_Nonnull)value fromRequest:(UNNotificationRequest *_Nonnull)request {
    NSNumber *badge = request.content.badge;
    UNMutableNotificationContent *content = [request.content mutableCopy];
    if (content.badge && value) {
        content.badge = [NSNumber numberWithInteger:([badge integerValue] - [value integerValue])];
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        return [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
    }
    return request;
}
#endif

@end
