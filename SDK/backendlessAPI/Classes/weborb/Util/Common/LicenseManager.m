//
//  LicenseManager.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "LicenseManager.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "DEBUG.h"
#import "BinaryCodec.h"
#import "Types.h"

@interface LicenseManager ()
-(void)licenseControl;
+(NSString *)getBundleIdentifier;
+(NSString *)getMainBundleIdentifier;
@end


@implementation LicenseManager
@synthesize isLicense, noLicenseCount;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(LicenseManager *)sharedInstance {
	static LicenseManager *sharedLicenseManager;
	@synchronized(self)
	{
		if (!sharedLicenseManager)
			sharedLicenseManager = [[LicenseManager alloc] init];
	}
	return sharedLicenseManager;
}

-(id)init {	
	if ( (self=[super init]) ) {
        [self licenseControl];
        noLicenseCount = 0;
	}
	
	return self;
}

#pragma mark -
#pragma mark Private Methods

-(void)licenseControl {
    [DebLog logN:@">>>>>>>>>> bundleID: '%@' = '%@'", [LicenseManager getBundleIdentifier], [LicenseManager getMainBundleIdentifier]];
#if TARGET_IPHONE_SIMULATOR
    // Don't check the license if running on the iPhone simulator.
    [DebLog logN:@">>>>>>>>>> License won't be checked (SIMULATOR)"];
    isLicense = YES;
#else 
	isLicense = [LicenseManager isLicenseByOwnBundleIdentifier];
#endif    
    [DebLog logN:@">>>>>>>>>> isLicense = %@", (isLicense)?@"YES":@"NO"];
}

+(void)printData:(NSData *)data {
    size_t size = [data length];
    uint8_t *buffer = malloc(size);
    [data getBytes:buffer length:size];
    
    // display
    printf("HASH: size=%d\n", (int)size);   
    for (int i = 0; i < size; i++) {
        if (i % 16 == 0) printf("\n");
        printf("%02x ", (uint)buffer[i]%0x100);
    }
    printf("\n\n");    
    free(buffer);
    
}

// sandbox Documents path 
+(NSString *)fileNameInDocumentDirectory:(NSString *)fileName { 
	// this is sandbox path
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0]; 
	
	NSLog(@"path -> %@", documentsDirectory);
	
	return [documentsDirectory stringByAppendingPathComponent:fileName]; 
}

+(NSData *)getHashBytes:(NSData *)plainText {
	CC_SHA1_CTX ctx;
	uint8_t * hashBytes = NULL;
	NSData * hash = nil;
	
	// Malloc a buffer to hold hash.
	hashBytes = malloc( CC_SHA1_DIGEST_LENGTH * sizeof(uint8_t) );
	memset((void *)hashBytes, 0x0, CC_SHA1_DIGEST_LENGTH);
	
	// Initialize the context.
	CC_SHA1_Init(&ctx);
	// Perform the hash.
	CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
	// Finalize the output.
	CC_SHA1_Final(hashBytes, &ctx);
	
	// Build up the SHA1 blob.
	hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)CC_SHA1_DIGEST_LENGTH];
	
	if (hashBytes) free(hashBytes);
	
	return hash;
}

// application bundleID
+(NSString *)getBundleIdentifier {
#if IS_TEMP_LICENSE_ALLOWED
    return [LicenseManager getTemporarilyBundleIdentifier:[Types getInfoPlist:@"CFBundleIdentifier"]];
#else
    return [Types getInfoPlist:@"CFBundleIdentifier"];
#endif
}

// manufacture bundleID
+(NSString *)getMainBundleIdentifier {
    NSString *bundleId = [LicenseManager getBundleIdentifier];
    const char *str = [bundleId UTF8String];
    for (int i = bundleId.length; i > 0; i--) {
        if (str[i-1] == '.')
            return [bundleId substringToIndex:i];
    }
    return @".";
}

+(NSData *)hashBundleIdentifier:(NSString *)bundleID {
    
    NSData *plain = [NSData dataWithBytes:[bundleID UTF8String] length:[bundleID length]];
    NSData *hash = [LicenseManager getHashBytes:plain];
    
    //[LicenseManager printData:hash];
    
    return hash;
}

// application bundleID hash
+(NSData *)hashBundleIdentifier {
    return [LicenseManager hashBundleIdentifier:[LicenseManager getBundleIdentifier]];
}

// manufacture bundleID hash
+(NSData *)hashMainBundleIdentifier {
    return [LicenseManager hashBundleIdentifier:[LicenseManager getMainBundleIdentifier]];
}

+(BOOL)isLicenseByDate {
    
#if IS_TEMP_LICENSE_ALLOWED
    
    NSArray *parts = [[Types getInfoPlist:@"CFBundleIdentifier"] componentsSeparatedByString:@".--"];
    if (parts.count < 2)
        return YES;
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyMMdd"];
    NSDate *limit = [dateFormatter dateFromString:(NSString *)parts[1]];
#if 1
    return !limit || ([[NSDate date] timeIntervalSince1970] < [limit timeIntervalSince1970]);
#else
    NSLog(@"LicenseManager -> isLicenseByDate: (0) limit = %@", limit);
    if (!limit)
        return YES;
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timelimit = [limit timeIntervalSince1970];
    NSLog(@"LicenseManager -> isLicenseByDate: (1) %f < %f ?", timestamp, timelimit);
    return timestamp < timelimit;
#endif
#else
    return YES;
#endif
}

#pragma mark -
#pragma mark Public Methods

+(BOOL)isExclusiveHttpUrl:(NSURL *)url {
#if 0 // need iOS 8>
    return [LICENSE_EXCLUSIVE_HTTP_HOSTS containsString:url.host.lowercaseString];
#else
    return [LICENSE_EXCLUSIVE_HTTP_HOSTS rangeOfString:url.host.lowercaseString].length;
#endif
}

+(BOOL)isExclusiveRtmpUrl:(NSURL *)url {
#if 0 // need iOS 8>
    return [LICENSE_EXCLUSIVE_RTMP_HOSTS containsString:url.host.lowercaseString];
#else
    return [LICENSE_EXCLUSIVE_RTMP_HOSTS rangeOfString:url.host.lowercaseString].length;
#endif
}

+(BOOL)isWeborbKey:(NSDictionary *)keys {
    NSString *whoAreYou = [keys valueForKey:@"WHO-ARE-YOU"];
    return ((whoAreYou) && [whoAreYou isEqualToString:@"weborb is the best"]);
}

+(BOOL)isBackendlessBehavior:(NSDictionary *)request response:(NSDictionary *)response {
    
    static NSString *CRITERIUM_HEADER_KEY = @"application-id";
    
    NSString *whoAreYou = request ? [request valueForKey:CRITERIUM_HEADER_KEY] : nil;
    NSString *iAmBackendless = response ? [response valueForKey:CRITERIUM_HEADER_KEY] : nil;
    
    //[DebLog logY:@"LicenseManager -> isBackendlessBehavior: whoAreYou = '%@', iAm = '%@', count = %d", whoAreYou, iAmBackendless, [LicenseManager sharedInstance].noLicenseCount];
    
    return whoAreYou && iAmBackendless && [whoAreYou isEqualToString:iAmBackendless];
    
}

+(void)writeLicenseFile:(NSString *)key {
    NSData *plain = [NSData dataWithBytes:[key UTF8String] length:[key length]];
    NSData *hash = [LicenseManager getHashBytes:plain];
    [hash writeToFile:[LicenseManager fileNameInDocumentDirectory:@"license.bin"] atomically:YES];  
}

+(void)writeLicenseFileByOwnBundleIdentifier {
    [LicenseManager writeLicenseFile:[LicenseManager getBundleIdentifier]];
}

+(BOOL)isLicenseByOwnBundleIdentifier {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"license" ofType:@"bin"];    
    //NSLog(@">>>> isLicenseByOwnBundleIdentifier >>>> path: %@", path);
    if (!path)
        return NO;
    
    NSData *license = [NSData dataWithContentsOfFile:path];
    //NSLog(@" (0) license: %@", license);
    if (!license)
        return NO;
    
    NSData *hash = [LicenseManager hashBundleIdentifier];    
    //NSLog(@" (1) application hash: %@", hash);
    if (hash && [license isEqualToData:hash])
        return [LicenseManager isLicenseByDate]; //YES
    
    hash = [LicenseManager hashMainBundleIdentifier];
    //NSLog(@" (2) manufacturer hash: %@", hash);
    return (hash && [license isEqualToData:hash]);
}

// application bundleID (coding the date part by temporarily marker ".--")
+(NSString *)getTemporarilyBundleIdentifier:(NSString *)bundleId {

#if IS_TEMP_LICENSE_ALLOWED
    NSArray *parts = [bundleId componentsSeparatedByString:@".--"];
    if (parts.count < 2)
        return bundleId;
    
    //NSLog(@">>>> getTemporarilyBundleIdentifier: (0) '%@'", bundleId);
    NSString *date = (NSString *)parts[1];
    bundleId = [NSString stringWithFormat:@"%@.%@", parts[0], [BEBase64 encode:(const uint8_t *)[date UTF8String] length:date.length]];
    //NSLog(@">>>> getTemporarilyBundleIdentifier: (1) '%@'", bundleId);
#endif
    return bundleId;
}


+(NSString*)GUIDString {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    return [(NSString *)string autorelease];
}

@end
