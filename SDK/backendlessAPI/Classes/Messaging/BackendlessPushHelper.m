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

#import "BackendlessPushHelper.h"
#import "JSONHelper.h"
#import "UserDefaultsHelper.h"

#define PUSH_TEMPLATES_USER_DEFAULTS @"iOSPushTemplates"

@implementation BackendlessPushHelper

+(BackendlessPushHelper *_Nonnull)sharedInstance {
    static BackendlessPushHelper *sharedBackendlessPushHelper;
    if (!sharedBackendlessPushHelper) {
        @synchronized(self) {
            sharedBackendlessPushHelper = [BackendlessPushHelper new];
        }
    }
    return sharedBackendlessPushHelper;
}

#if (TARGET_OS_IOS || TARGET_OS_SIMULATOR) && !TARGET_OS_TV && ! TARGET_OS_WATCH
-(void)processMutableContent:(UNNotificationRequest *_Nonnull)request withContentHandler:(void(^_Nonnull)(UNNotificationContent *_Nonnull))contentHandler NS_AVAILABLE_IOS(10_0) {

    if ([request.content.userInfo valueForKey:@"ios_immediate_push"]) {
        request = [self prepareRequestWithIosImmediatePush:request];
    }

    if ([request.content.userInfo valueForKey:@"template_name"]) {
        request = [self prepareRequestWithTemplate:request];
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

-(UNNotificationRequest *)prepareRequestWithIosImmediatePush:(UNNotificationRequest *)request {
    NSString *JSONString = [request.content.userInfo valueForKey:@"ios_immediate_push"];
    NSDictionary *iosPushTemplate = [jsonHelper dictionaryFromJson:JSONString];
    return [self createRequestFromTemplate:[self dictionaryWithoutNulls:iosPushTemplate] request:request];
}

-(UNNotificationRequest *)prepareRequestWithTemplate:(UNNotificationRequest *)request {
    NSString *templateName = [request.content.userInfo valueForKey:@"template_name"];
    NSDictionary *iosPushTemplates = [userDefaultsHelper readFromUserDefaultsWithKey:PUSH_TEMPLATES_USER_DEFAULTS withSuiteName:@"group.com.backendless.PushTemplates"];
    NSDictionary *iosPushTemplate = [iosPushTemplates valueForKey:templateName];
    return [self createRequestFromTemplate:[self dictionaryWithoutNulls:iosPushTemplate] request:request];
}

-(NSDictionary *)dictionaryWithoutNulls:(NSDictionary *)dictionary {
    NSMutableDictionary *resultDictionary = [dictionary mutableCopy];
    NSArray *keysForNullValues = [resultDictionary allKeysForObject:[NSNull null]];
    [resultDictionary removeObjectsForKeys:keysForNullValues];
    return resultDictionary;
}

-(UNNotificationRequest *)createRequestFromTemplate:(NSDictionary *)iosPushTemplate request:(UNNotificationRequest *)request {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.body = [[[request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];
    if (request.content.title) {
        content.title = request.content.title;
    }
    else {
        content.title = [iosPushTemplate valueForKey:@"alertTitle"];
    }
    if (request.content.subtitle) {
       content.subtitle = request.content.subtitle;
    }
    else {
        content.subtitle = [iosPushTemplate valueForKey:@"alertSubtitle"];
    }
    
    NSArray *actionsArray = [iosPushTemplate valueForKey:@"actions"];
    content.categoryIdentifier = [self setActions:actionsArray];
    
    if ([iosPushTemplate valueForKey:@"sound"]) {
        content.sound = [UNNotificationSound soundNamed:[iosPushTemplate valueForKey:@"sound"]];
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

-(NSString *)setActions:(NSArray *)actions {
    NSMutableArray *categoryActions = [NSMutableArray new];

    for (NSDictionary *action in actions) {
        NSString *actionId = [action valueForKey:@"id"];
        NSString *actionTitle = [action valueForKey:@"title"];
        NSNumber *actionOptions = [action valueForKey:@"options"];
        UNNotificationActionOptions options = [actionOptions integerValue];
        [categoryActions addObject:[UNNotificationAction actionWithIdentifier:actionId title:actionTitle options:options]];
    }
    NSString *categoryId = @"buttonActionsTemplate";
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryId actions:categoryActions intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [UNUserNotificationCenter.currentNotificationCenter setNotificationCategories:[NSSet setWithObject:category]];
    return categoryId;
}

#endif

@end
