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

-(UNNotificationRequest *)prepareRequestWithIosImmediatePush:(UNNotificationRequest *)request {
    NSString *JSONString = [request.content.userInfo valueForKey:@"ios_immediate_push"];
    NSDictionary *iosPushTemplate = [jsonHelper dictionaryFromJson:JSONString];
    return [self createRequestFromTemplate:[self dictionaryWithoutNulls:iosPushTemplate] request:request];
}

-(UNNotificationRequest *)prepareRequestWithTemplate:(UNNotificationRequest *)request {
    NSString *templateName = [request.content.userInfo valueForKey:@"template_name"];
    NSDictionary *iosPushTemplates = [userDefaultsHelper readFromUserDefaultsWithKey:PUSH_TEMPLATES_USER_DEFAULTS withSuiteName:[userDefaultsHelper getAppGroup]];
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
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    NSMutableDictionary *aps = [NSMutableDictionary new];
    NSMutableDictionary *apsAlert = [NSMutableDictionary new];
    
    // check if silent
    NSNumber *contentAvailable = [iosPushTemplate valueForKey:@"contentAvailable"];
    NSInteger contentAvailableInt = [contentAvailable integerValue];
    if (contentAvailableInt == 1) {
        
    }
    else {
        if ([request.content.userInfo valueForKey:@"message"]) {
            content.body = [request.content.userInfo valueForKey:@"message"];
            [apsAlert setObject:content.body forKey:@"body"];
        }
        else {
            content.body = [[[request.content.userInfo valueForKey:@"aps"] valueForKey:@"alert"] valueForKey:@"body"];
            [apsAlert setObject:content.body forKey:@"body"];
        }
        
        if ([request.content.userInfo valueForKey:@"ios-alert-title"]) {
            content.title = [request.content.userInfo valueForKey:@"ios-alert-title"];
            [apsAlert setObject:content.title forKey:@"title"];
        }
        else {
            content.title = [iosPushTemplate valueForKey:@"alertTitle"];
            [apsAlert setObject:content.title forKey:@"title"];
        }
        
        if ([request.content.userInfo valueForKey:@"ios-alert-subtitle"]) {
            [apsAlert setObject:content.subtitle forKey:@"subtitle"];
        }
        else {
            content.subtitle = [iosPushTemplate valueForKey:@"alertSubtitle"];
            [apsAlert setObject:content.subtitle forKey:@"subtitle"];
        }
        [aps setObject:apsAlert forKey:@"alert"];
        
        if ([iosPushTemplate valueForKey:@"sound"]) {
            content.sound = [UNNotificationSound soundNamed:[iosPushTemplate valueForKey:@"sound"]];
            [aps setObject:[iosPushTemplate valueForKey:@"sound"] forKey:@"sound"];
        }
        else {
            content.sound = [UNNotificationSound defaultSound];
            [aps setObject:@"default" forKey:@"sound"];
        }
        
        if (request.content.badge) {
            content.badge = request.content.badge;
            [aps setObject:content.badge forKey:@"badge"];
        }
        else {
            NSNumber *badge = [iosPushTemplate valueForKey:@"badge"];
            content.badge = badge;
            [aps setObject:content.badge forKey:@"badge"];
        }
        
        [userInfo setObject:aps forKey:@"aps"];
        
        if ([iosPushTemplate valueForKey:@"attachmentUrl"]) {
            NSString *urlString = [iosPushTemplate valueForKey:@"attachmentUrl"];
            [userInfo setObject:urlString forKey:@"attachment-url"];
        }
        
        if ([iosPushTemplate valueForKey:@"customHeaders"]) {
            NSDictionary *customHeaders = [iosPushTemplate valueForKey:@"customHeaders"];
            for (NSString *headerKey in [customHeaders allKeys]) {
                if ([request.content.userInfo valueForKey:headerKey]) {
                    [userInfo setObject:[request.content.userInfo valueForKey:headerKey] forKey:headerKey];
                }
                else {
                    [userInfo setObject:[customHeaders valueForKey:headerKey] forKey:headerKey];
                }
            }
        }
        
        if (@available(iOS 12.0, *)) {
            if([iosPushTemplate valueForKey:@"threadId"]) {
                content.threadIdentifier = [iosPushTemplate valueForKey:@"threadId"];
                [userInfo setObject:content.threadIdentifier forKey:@"thread-id"];
            }
            if([iosPushTemplate valueForKey:@"summaryFormat"]) {
                content.summaryArgument = [iosPushTemplate valueForKey:@"summaryFormat"];
                [userInfo setObject:content.summaryArgument forKey:@"summary-arg"];
            }
        }
        
        content.userInfo = userInfo;
        
        NSArray *actionsArray = [iosPushTemplate valueForKey:@"actions"];
        content.categoryIdentifier = [self setActions:actionsArray];
    }
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
    return [UNNotificationRequest requestWithIdentifier:@"request" content:content trigger:trigger];
}

-(NSString *)setActions:(NSArray *)actions {
    NSMutableArray *categoryActions = [NSMutableArray new];
    for (NSDictionary *action in actions) {
        NSString *actionId = [action valueForKey:@"id"];
        NSString *actionTitle = [action valueForKey:@"title"];
        NSNumber *actionOptions = [action valueForKey:@"options"];
        UNNotificationActionOptions options = [actionOptions integerValue];
        
        if ([[action valueForKey:@"inlineReply"] isEqual:@YES]) {
            NSString *textInputPlaceholder = @"Input text here...";
            if (![[action valueForKey:@"textInputPlaceholder"] isKindOfClass:[NSNull class]]) {
                if ([[action valueForKey:@"textInputPlaceholder"] length] > 0) {
                    textInputPlaceholder = [action valueForKey:@"textInputPlaceholder"];
                }
            }
            NSString *inputButtonTitle = @"Send";
            if (![[action valueForKey:@"inputButtonTitle"] isKindOfClass:[NSNull class]]) {
                if ([[action valueForKey:@"inputButtonTitle"] length] > 0) {
                    inputButtonTitle = [action valueForKey:@"inputButtonTitle"];
                }
            }
            [categoryActions addObject:[UNTextInputNotificationAction actionWithIdentifier:actionId title:actionTitle options:options textInputButtonTitle:inputButtonTitle textInputPlaceholder:textInputPlaceholder]];
        }
        else {
            [categoryActions addObject:[UNNotificationAction actionWithIdentifier:actionId title:actionTitle options:options]];
        }
    }
    NSString *categoryId = @"buttonActionsTemplate";
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:categoryId actions:categoryActions intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
    return categoryId;
}

#endif

@end
