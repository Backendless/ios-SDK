//
//  UserDefaultsHelper.m
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

#import "UserDefaultsHelper.h"

@implementation UserDefaultsHelper

+(instancetype)sharedInstance {
    static UserDefaultsHelper *sharedUserDefaultsHelper;
    @synchronized(self) {
        if (!sharedUserDefaultsHelper)
            sharedUserDefaultsHelper = [UserDefaultsHelper new];
    }
    return sharedUserDefaultsHelper;
}

-(void)writeToUserDefaults:(NSDictionary *)dictionary withKey:(NSString *)key withSuiteName:(NSString *)suiteName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (suiteName) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    }
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:dictionary] forKey:key];
    [userDefaults synchronize];
}

-(NSDictionary *)readFromUserDefaultsWithKey:(NSString *)key withSuiteName:(NSString *)suiteName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (suiteName) {
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
    }
    NSData *data = [userDefaults objectForKey:key];
    return [[NSDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

-(NSString *)getAppGroup {
    NSString *projectName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString *path = [[NSBundle mainBundle] pathForResource:projectName ofType:@"entitlements"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray<NSString *> *appGroups = [dict objectForKey:@"com.apple.security.application-groups"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] 'group.backendlesspush.'"];
    NSString *appGroup = [[appGroups filteredArrayUsingPredicate:predicate] firstObject];
    return appGroup;
}

@end
