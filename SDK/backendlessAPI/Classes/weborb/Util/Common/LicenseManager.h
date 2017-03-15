//
//  LicenseManager.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LICENSE_TIMER_CRITERIUM 120.0f
#define LICENSE_QUANTITY_CRITERIUM 5
#define IS_TEMP_LICENSE_ALLOWED 1
#define LICENSE_EXCLUSIVE_HTTP_HOSTS @"localhost,api.backendless.com,api.gmo.backendless.com,api.gmo-mbaas.com"
#define LICENSE_EXCLUSIVE_RTMP_HOSTS @"localhost,wowza.backendless.com,media.backendless.com,10.0.1.62,157.7.216.202,157.7.216.200"

@interface LicenseManager : NSObject {
    BOOL    isLicense;
    long    noLicenseCount;
}
@property (readonly) BOOL isLicense;
@property long noLicenseCount;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(LicenseManager *)sharedInstance;
//
+(BOOL)isExclusiveHttpUrl:(NSURL *)url;
+(BOOL)isExclusiveRtmpUrl:(NSURL *)url;
+(BOOL)isWeborbKey:(NSDictionary *)keys;
+(BOOL)isBackendlessBehavior:(NSDictionary *)request response:(NSDictionary *)response;
+(void)writeLicenseFile:(NSString *)key;
+(void)writeLicenseFileByOwnBundleIdentifier;
+(BOOL)isLicenseByOwnBundleIdentifier;
+(NSString *)getTemporarilyBundleIdentifier:(NSString *)bundleId;
+(NSString*)GUIDString;
@end
