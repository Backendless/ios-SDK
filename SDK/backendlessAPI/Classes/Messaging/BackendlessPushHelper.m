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
#import "JSONHelper.h"

@implementation BackendlessPushHelper

#if TARGET_OS_IOS || TARGET_OS_SIMULATOR
+(void)processMutableContent:(UNNotificationRequest *_Nonnull)request withContentHandler:(void(^_Nonnull)(UNNotificationContent *_Nonnull))contentHandler NS_AVAILABLE_IOS(10_0) {
    
    if ([request.content.userInfo valueForKey:@"ios_immediate_push"]) {
        request = [self prepareNotificationRequestWithTemplate:request];
    }
    
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

+(UNNotificationRequest *)prepareNotificationRequestWithTemplate:(UNNotificationRequest *)request {

    NSString *JSONString = [request.content.userInfo valueForKey:@"ios_immediate_push"];
    NSMutableDictionary *iosPushTemplate = [NSMutableDictionary new];

    NSDictionary *dict = [jsonHelper dictionaryFromJson:JSONString];
    for (NSString *key in [dict allKeys]) {
        if (![[dict valueForKey:key] isKindOfClass:[NSNull class]]) {
            [iosPushTemplate setObject:[dict valueForKey:key] forKey:key];
        }
    }

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.body = [[[request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];

    NSArray *actionsArray = [[iosPushTemplate valueForKey:@"buttonTemplate"] valueForKey:@"actions"];
    content.categoryIdentifier = [self setActions:actionsArray];

    if ([iosPushTemplate valueForKey:@"alertTitle"]) {
        content.title = [iosPushTemplate valueForKey:@"alertTitle"];
    }
    else {
        content.title = request.content.title;
    }

    if ([iosPushTemplate valueForKey:@"alertSubtitle"]) {
        content.subtitle = [iosPushTemplate valueForKey:@"alertSubtitle"];
    }
    else {
        content.subtitle = request.content.subtitle;
    }

    if ([iosPushTemplate valueForKey:@"sound"]) {
        // ????
    }
    else {
        content.sound = [UNNotificationSound defaultSound];
    }

    if ([iosPushTemplate valueForKey:@"badge"]) {
        NSNumber *badge = [iosPushTemplate valueForKey:@"badge"];
        content.badge = badge;
    }
    else {
        content.badge = request.content.badge ;
    }

    if ([iosPushTemplate valueForKey:@"attachmentUrl"]) {
        NSString *urlString = [iosPushTemplate valueForKey:@"attachmentUrl"];
        NSDictionary *userInfo = @{@"attachment-url" : urlString};
        content.userInfo = userInfo;
    }

    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    return [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
}

+(NSString *)setActions:(NSArray *)actions {
    NSMutableArray *categoryActions = [NSMutableArray new];
    
    for (NSDictionary *action in actions) {
        NSString *actionId = [action valueForKey:@"id"];
        NSString *actionTitle = [action valueForKey:@"title"];
        NSInteger actionOptions = 3;
        
        UNNotificationActionOptions options = actionOptions;
        [categoryActions addObject:[UNNotificationAction actionWithIdentifier:actionId title:actionTitle options:options]];
    }
    
    NSString *categoryId = @"buttonActionsTemplate";
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryId actions:categoryActions intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [UNUserNotificationCenter.currentNotificationCenter setNotificationCategories:[NSSet setWithObject:category]];
    return categoryId;
}

#endif

@end
