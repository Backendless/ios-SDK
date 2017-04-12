//
//  MessagingService.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#define POLLING_INTERVAL 5000

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#else
#import <IOKit/IOKitLib.h>
#endif

#import "MessagingService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BESubscription.h"
#import "BodyParts.h"
#import "UICKeyChainStore.h"
#import "KeychainDataStore.h"

#define FAULT_NO_DEVICE_ID [Fault fault:@"Device ID is not set" detail:@"Device ID is not set" faultCode:@"5900"]
#define FAULT_NO_DEVICE_TOKEN [Fault fault:@"Device token is not set" detail:@"Device token is not set" faultCode:@"5901"]
#define FAULT_NO_CHANNEL [Fault fault:@"Channel is not set for publishing" detail:@"Channel is not set for publishing" faultCode:@"5902"]
#define FAULT_NO_MESSAGE [Fault fault:@"Message is not set for publishing" detail:@"Message is not set for publishing" faultCode:@"5903"]
#define FAULT_NO_MESSAGE_ID [Fault fault:@"Message ID is not set" detail:@"Message ID is not set" faultCode:@"5904"]
#define FAULT_NO_SUBSCRIPTION_ID [Fault fault:@"Subscription ID is not set" detail:@"Subscription ID is not set" faultCode:@"5905"]
#define FAULT_NO_BODY [Fault fault:@"Message body is not set for email" detail:@"Message body is not set for email" faultCode:@"5906"]
#define FAULT_NO_RECIPIENT [Fault fault:@"No recipient is set for email" detail:@"No recipient is set for email" faultCode:@"5907"]

// Default channel name
static  NSString *DEFAULT_CHANNEL_NAME = @"default";
// SERVICE NAME
static NSString *SERVER_DEVICE_REGISTRATION_PATH = @"com.backendless.services.messaging.DeviceRegistrationService";
static NSString *SERVER_MESSAGING_SERVICE_PATH = @"com.backendless.services.messaging.MessagingService";
static NSString *SERVER_MAIL_SERVICE_PATH = @"com.backendless.services.mail.CustomersEmailService";
// METHOD NAMES
static NSString *METHOD_REGISTER_DEVICE = @"registerDevice";
static NSString *METHOD_GET_REGISTRATIONS = @"getDeviceRegistrationByDeviceId";
static NSString *METHOD_UNREGISTER_DEVICE = @"unregisterDevice";
static NSString *METHOD_PUBLISH = @"publish";
static NSString *METHOD_CANCEL = @"cancel";
static NSString *METHOD_POLLING_SUBSCRIBE = @"subscribeForPollingAccess";
static NSString *METHOD_POLL_MESSAGES = @"pollMessages";
static NSString *METHOD_SEND_EMAIL = @"send";
static NSString *METHOD_MESSAGE_STATUS = @"getMessageStatus";
// UICKeyChainStore service name
static  NSString *kBackendlessApplicationUUIDKey = @"kBackendlessApplicationUUIDKeychain";

@interface MessagingService() {
    DeviceRegistration  *deviceRegistration;
}

// sync methods
-(NSString *)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions;
// async methods
-(void)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder;
// callbacks
-(id)onRegistering:(id)response;
-(id)onUnregistering:(id)response;
-(id)onSubscribe:(id)response;
// utils
-(NSString *)serialNumber;
@end


@implementation MessagingService
@synthesize pollingFrequencyMs;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
- (NSString *)serialNumber
{
#if 1 // store in keychain
#if 1 // use KeychainDataStore
    KeychainDataStore *keychainStore = [[KeychainDataStore alloc] initWithService:kBackendlessApplicationUUIDKey withGroup:nil];
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSData *data = [keychainStore get:bundleId];
    NSString *UUID = data?[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]:nil;
    if (!UUID) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [keychainStore save:bundleId data:[UUID dataUsingEncoding:NSUTF8StringEncoding]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self unregisterDeviceAsync:[[UIDevice currentDevice].identifierForVendor UUIDString] responder:nil];
        });
    }
    return UUID;
#else // use UICKeyChainStore
    UICKeyChainStore *keychainStore = [UICKeyChainStore keyChainStore];
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    NSString *UUID = [UICKeyChainStore stringForKey:bundleId service:kBackendlessApplicationUUIDKey];
    if (!UUID) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [UICKeyChainStore setString:UUID forKey:bundleId service:kBackendlessApplicationUUIDKey];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self unregisterDeviceAsync:[[UIDevice currentDevice].identifierForVendor UUIDString] responder:nil];
        });
    }
    return UUID;
#endif
#else // store in NSUserDefaults (NOT USEFUL: changes after app was removed)
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:kBackendlessApplicationUUIDKey];
    if (!UUID) {
        
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        UUID = (NSString *)CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        
        [[NSUserDefaults standardUserDefaults] setObject:UUID forKey:kBackendlessApplicationUUIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return UUID;
#endif
}
#else // OSX
-(NSString *)serialNumber {
    
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;
    
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                 CFSTR(kIOPlatformSerialNumberKey),
                                                                 kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    
    NSString *serialNumberAsNSString = nil;
    if (serialNumberAsCFString) {
        serialNumberAsNSString = [NSString stringWithString:(NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }
    
    return serialNumberAsNSString;
}
#endif

-(id)init {
    
    if ( (self=[super init]) ) {
        
        self.pollingFrequencyMs = POLLING_INTERVAL;
        _subscriptions = [HashMap new];
#if _OLD_NOTIFICATION_
        self.categories = nil;
#endif
        
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.management.DeviceRegistrationDto" mapped:[DeviceRegistration class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.Message" mapped:[Message class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.messaging.MessageStatus" mapped:[MessageStatus class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.PublishOptions" mapped:[PublishOptions class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.messaging.DeliveryOptions" mapped:[DeliveryOptions class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.mail.BodyParts" mapped:[BodyParts class]];
        
        deviceRegistration = [DeviceRegistration new];
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        
#if _OLD_NOTIFICATION_
        // if >= iOS8
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
            self.notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        }
#if 0
        else {
            self.notificationTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        }
#endif
#endif
        
        UIDevice *device = [UIDevice currentDevice];
#if 1   // use generated UUID which is saved in keychain with bundleId as key
        NSString *deviceId = [self serialNumber];
#else   // use device.identifierForVendor as UUID ( !!! NOT USEFUL: cause of additional registration after app was removed !!! )
        NSString *deviceId = [device.identifierForVendor UUIDString];
#endif
        deviceRegistration.deviceToken = device.name;
        deviceRegistration.deviceId = deviceId ? deviceId : [backendless GUIDString];
        deviceRegistration.os = @"IOS";
        deviceRegistration.osVersion = device.systemVersion;
        
#else   // OSX
        deviceRegistration.os = @"OSX";
        NSString *deviceId = [self serialNumber];
        deviceRegistration.deviceId = deviceId ? deviceId : [backendless GUIDString];
#endif
        
        [DebLog log:@"MessagingService -> init: deviceToken = %@, deviceId = %@, os = %@, osVersion = %@", deviceRegistration.deviceToken, deviceRegistration.deviceId, deviceRegistration.os, deviceRegistration.osVersion];
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC MessagingService"];
    
    [deviceRegistration release];
    [self.subscriptions release];
#if _OLD_NOTIFICATION_
    [self.categories release];
#endif
    
    [super dealloc];
}


#pragma mark -
#pragma mark Public Methods

// utilites

-(DeviceRegistration *)currentDevice {
    return deviceRegistration;
}

-(NSString *)deviceTokenAsString:(NSData *)token {
    NSString *str = [NSString stringWithFormat:@"%@", token];
    return [[[str stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
}

// sync methods with fault return (as exception)

-(NSString *)registerDevice:(NSData *)deviceToken {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}

- (NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}

-(NSString *)registerDevice {
    if (!deviceRegistration.deviceToken) {
        [DebLog logY:@"MessagingService -> registerDevice (ERROR): deviceToken is not exist"];
        return [backendless throwFault:FAULT_NO_DEVICE_TOKEN];
    }
    [DebLog log:@"MessagingService -> registerDevice (SYNC): %@", deviceRegistration];
    NSArray *args = [NSArray arrayWithObjects:deviceRegistration, nil];
    id result = [invoker invokeSync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_REGISTER_DEVICE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    return (deviceRegistration.id = [NSString stringWithFormat:@"%@", result]);
}

-(DeviceRegistration *)getRegistration:(NSString *)deviceId {
    if (!deviceId)
        return [backendless throwFault:FAULT_NO_DEVICE_ID];
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    return [invoker invokeSync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_GET_REGISTRATIONS args:args];
}

-(id)unregisterDevice {
    return [self unregisterDevice:deviceRegistration.deviceId];
}

-(id)unregisterDevice:(NSString *)deviceId {
    
    if (!deviceId)
        return [backendless throwFault:FAULT_NO_DEVICE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    id result = [invoker invokeSync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_UNREGISTER_DEVICE args:args];
    if (result && ![result isKindOfClass:[Fault class]]) {
        if ([result boolValue]) deviceRegistration.id = nil;
    }
    
    return result;
}

-(MessageStatus *)publish:(NSString *)channelName message:(id)message {
    return [self publish:channelName message:message publishOptions:nil deliveryOptions:nil];
}

-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions {
    return [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:nil];
}

-(MessageStatus *)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions {
    return [self publish:channelName message:message publishOptions:nil deliveryOptions:deliveryOptions];
}

-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions {
    if (!channelName)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    if (!message)
        return [backendless throwFault:FAULT_NO_MESSAGE];
    NSMutableArray *args = [NSMutableArray arrayWithObjects:channelName, message, publishOptions?publishOptions:[NSNull null], nil];
    if (deliveryOptions)
        [args addObject:deliveryOptions];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_PUBLISH args:args];
}

-(id)cancel:(NSString *)messageId {
    
    if (!messageId)
        return [backendless throwFault:FAULT_NO_MESSAGE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:messageId, nil];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_CANCEL args:args];
}

-(BESubscription *)subscribe:(NSString *)channelName {
    return [self subscribe:channelName subscriptionResponder:nil subscriptionOptions:nil];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder {
    return [self subscribe:channelName subscriptionResponder:subscriptionResponder subscriptionOptions:nil];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    return [self subscribe:[BESubscription subscription:channelName responder:subscriptionResponder] subscriptionOptions:subscriptionOptions];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock {
    return [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    return [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] subscriptionOptions:subscriptionOptions];
}

-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    
    if (!subscription)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    
    subscription.deliveryMethod = [subscriptionOptions valDeliveryMethod];
    subscriptionOptions.deviceId = deviceRegistration.deviceId;
    
    id result = [self subscribeForPollingAccess:subscription.channelName subscriptionOptions:subscriptionOptions];
    if ([result isKindOfClass:[Fault class]])
        return result;
    
    subscription.subscriptionId = (NSString *)result;
    return subscription;
}

-(NSArray *)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId {
    
    if (!channelName)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    
    if (!subscriptionId)
        return [backendless throwFault:FAULT_NO_SUBSCRIPTION_ID];
    
    NSArray *args = [NSArray arrayWithObjects:channelName, subscriptionId, nil];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLL_MESSAGES args:args];
}

-(id)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients {
    return [self sendEmail:subject body:[BodyParts bodyText:messageBody html:nil] to:recipients attachment:nil];
}

-(id)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients {
    return [self sendEmail:subject body:[BodyParts bodyText:nil html:messageBody] to:recipients attachment:nil];
}

-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients {
    return [self sendEmail:subject body:bodyParts to:recipients attachment:nil];
}

-(id)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments {
    
    if (!bodyParts || ![bodyParts isBody])
        return [backendless throwFault:FAULT_NO_BODY];
    
    if (!recipients || !recipients.count)
        return [backendless throwFault:FAULT_NO_RECIPIENT];
    
    NSArray *args = @[(subject)?subject:@"", bodyParts, recipients, (attachments)?attachments:@[]];
    return [invoker invokeSync:SERVER_MAIL_SERVICE_PATH method:METHOD_SEND_EMAIL args:args];
}

-(MessageStatus*)getMessageStatus:(NSString*)messageId {
    if (!messageId)
        return [backendless throwFault:FAULT_NO_MESSAGE_ID];
    
    NSArray *args = [NSMutableArray arrayWithObjects:messageId, nil];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_MESSAGE_STATUS args:args];
}

// async methods with responder

-(void)registerDeviceAsync:(id<IResponder>)responder {
    
    if (!deviceRegistration.deviceToken) {
        [DebLog logY:@"MessagingService -> registerDeviceASync (ERROR): deviceToken is not exist"];
        return [responder errorHandler:FAULT_NO_DEVICE_TOKEN];
    }
    
    [DebLog log:@"MessagingService -> registerDeviceAsync (ASYNC): %@", deviceRegistration];
    
    NSArray *args = [NSArray arrayWithObjects:deviceRegistration, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onRegistering:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_REGISTER_DEVICE args:args responder:_responder];
}

-(void)unregisterDeviceAsync:(id<IResponder>)responder {
    return [self unregisterDeviceAsync:deviceRegistration.deviceId responder:responder];
}

-(void)unregisterDeviceAsync:(NSString *)deviceId responder:(id<IResponder>)responder {
    
    if (!deviceId)
        return [responder errorHandler:FAULT_NO_DEVICE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUnregistering:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_UNREGISTER_DEVICE args:args responder:_responder];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions responder:(id <IResponder>)responder {
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    if (!message)
        return [responder errorHandler:FAULT_NO_MESSAGE];
    NSMutableArray *args = [NSMutableArray arrayWithObjects:channelName, message, publishOptions?publishOptions:[NSNull null], nil];
    if (deliveryOptions)
        [args addObject:deliveryOptions];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_PUBLISH args:args responder:responder];
}

-(void)cancel:(NSString *)messageId responder:(id <IResponder>)responder {
    
    if (!messageId)
        return [responder errorHandler:FAULT_NO_MESSAGE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:messageId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_CANCEL args:args responder:responder];
}


-(void)subscribe:(NSString *)channelName responder:(id <IResponder>)responder {
    [self subscribe:channelName subscriptionResponder:nil subscriptionOptions:nil responder:responder];
}

-(void)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder responder:(id <IResponder>)responder {
    [self subscribe:channelName subscriptionResponder:subscriptionResponder subscriptionOptions:nil responder:responder];
}

-(void)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    [self subscribe:[BESubscription subscription:channelName responder:subscriptionResponder] subscriptionOptions:subscriptionOptions responder:responder];
}

-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    
    if (!subscription)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    
    subscription.deliveryMethod = [subscriptionOptions valDeliveryMethod];
    subscriptionOptions.deviceId = deviceRegistration.deviceId;
    
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onSubscribe:) selErrorHandler:nil];
    _responder.context = [subscription retain];
    _responder.chained = responder;
    [self subscribeForPollingAccess:subscription.channelName subscriptionOptions:subscriptionOptions responder:_responder];
}

-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId responder:(id <IResponder>)responder {
    
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    
    if (!subscriptionId)
        return [responder errorHandler:FAULT_NO_SUBSCRIPTION_ID];
    
    NSArray *args = [NSArray arrayWithObjects:channelName, subscriptionId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLL_MESSAGES args:args responder:responder];
}

-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder {
    [self sendEmail:subject body:[BodyParts bodyText:messageBody html:nil] to:recipients attachment:nil responder:responder];
}

-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder {
    [self sendEmail:subject body:[BodyParts bodyText:nil html:messageBody] to:recipients attachment:nil responder:responder];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients responder:(id <IResponder>)responder {
    [self sendEmail:subject body:bodyParts to:recipients attachment:nil responder:responder];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments responder:(id <IResponder>)responder {
    
    if (!bodyParts || ![bodyParts isBody])
        return [responder errorHandler:FAULT_NO_BODY];
    
    if (!recipients || !recipients.count)
        return [responder errorHandler:FAULT_NO_RECIPIENT];
    
    NSArray *args = @[(subject)?subject:@"", bodyParts, recipients, (attachments)?attachments:@[]];
    [invoker invokeAsync:SERVER_MAIL_SERVICE_PATH method:METHOD_SEND_EMAIL args:args responder:responder];
}

// async methods with block-based callbacks

-(void)registerDeviceAsync:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDeviceAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)registerDevice:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self registerDeviceAsync:responder];
}

-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self registerDeviceAsync:responder];
}

-(void)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.expiration = expiration;
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self registerDeviceAsync:responder];
}

-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self registerDeviceAsync:responder];
}

-(void)getRegistration:(NSString *)deviceId response:(void(^)(DeviceRegistration *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!deviceId)
        return [responder errorHandler:FAULT_NO_DEVICE_ID];
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_GET_REGISTRATIONS args:args responder:responder];
}

-(void)unregisterDeviceAsync:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self unregisterDeviceAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)unregisterDeviceAsync:(NSString *)deviceId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self unregisterDeviceAsync:deviceId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)publish:(NSString *)channelName message:(id)message response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self publish:channelName message:message publishOptions:nil deliveryOptions:nil responder:chainedResponder];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:nil responder:chainedResponder];
}

-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self publish:channelName message:message publishOptions:nil deliveryOptions:deliveryOptions responder:chainedResponder];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:deliveryOptions responder:chainedResponder];
}

-(void)cancel:(NSString *)messageId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self cancel:messageId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] subscriptionOptions:subscriptionOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  subscribe:subscription subscriptionOptions:subscriptionOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self pollMessages:channelName subscriptionId:subscriptionId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendTextEmail:subject body:messageBody to:recipients responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendHTMLEmail:subject body:messageBody to:recipients responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendEmail:subject body:bodyParts to:recipients responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendEmail:subject body:bodyParts to:recipients attachment:attachments responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getMessageStatus:(NSString*)messageId response:(void(^)(MessageStatus*))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!messageId)
        return [chainedResponder errorHandler:FAULT_NO_MESSAGE_ID];
    
    NSMutableArray *args = [NSMutableArray arrayWithObjects:messageId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_MESSAGE_STATUS args:args responder:chainedResponder];
}

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

-(void)registerForRemoteNotifications {
    
    /*
     typedef NS_OPTIONS(NSUInteger, UIUserNotificationType) {
     UIUserNotificationTypeNone    = 0,      // the application may not present any UI upon a notification being received
     UIUserNotificationTypeBadge   = 1 << 0, // the application may badge its icon upon a notification being received
     UIUserNotificationTypeSound   = 1 << 1, // the application may play a sound upon a notification being received
     UIUserNotificationTypeAlert   = 1 << 2, // the application may display an alert upon a notification being received
     } NS_ENUM_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
     */
    
    // check if iOS8
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
#if _OLD_NOTIFICATION_
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:self.notificationTypes categories:self.categories];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
#if 0
    else {
        //UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:self.notificationTypes];
    }
#endif
}

-(void)unregisterFromRemoteNotifications {
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
// for pubsub using silent remote notification (SubscriptionOptions.deliveryMethod = DELIVERY_PUSH)

-(void)registerForPushPubSub {
    [self registerForRemoteNotifications];
}

-(void)unregisterFromPushPubSub {
    [self unregisterFromRemoteNotifications];
}

-(void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *remoteDict = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteDict) [self didReceiveRemoteNotification:remoteDict];
}

-(void)applicationWillTerminate {
    [self unregisterFromRemoteNotifications];
    if ([self.pushReceiver respondsToSelector:@selector(applicationWillTerminate)]) {
        [self.pushReceiver applicationWillTerminate];
    }
}

-(void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    
#if 1  // async
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    [self registerDeviceAsync:
     ^(NSString *deviceRegistrationId) {
         [DebLog log:@"MessagingService -> application:didRegisterForRemoteNotificationsWithDeviceToken: deviceRegistrationId = %@", deviceRegistrationId];
         if ([self.pushReceiver respondsToSelector:@selector(didRegisterForRemoteNotificationsWithDeviceId:fault:)]) {
             [self.pushReceiver didRegisterForRemoteNotificationsWithDeviceId:deviceRegistrationId fault:nil];
         }
     }
                        error:^(Fault *fault) {
                            [DebLog log:@"MessagingService -> application:didRegisterForRemoteNotificationsWithDeviceToken: %@", fault];
                            if ([self.pushReceiver respondsToSelector:@selector(didRegisterForRemoteNotificationsWithDeviceId:fault:)]) {
                                [self.pushReceiver didRegisterForRemoteNotificationsWithDeviceId:nil fault:fault];
                            }
                        }];
#else // sync
    @try {
        NSString *deviceRegistrationId = [self registerDeviceToken:deviceToken];
        [DebLog log:@"MessagingService -> application:didRegisterForRemoteNotificationsWithDeviceToken: -> registerDeviceToken: deviceRegistrationId = %@", deviceRegistrationId];
        if ([self.pushReceiver respondsToSelector:@selector(didRegisterForRemoteNotificationsWithDeviceId:fault:)]) {
            [self.pushReceiver didRegisterForRemoteNotificationsWithDeviceId:deviceRegistrationId fault:nil];
        }
    }
    @catch (Fault *fault) {
        [DebLog log:@"MessagingService -> application:didRegisterForRemoteNotificationsWithDeviceToken: -> registerDeviceToken: %@", fault];
        if ([self.pushReceiver respondsToSelector:@selector(didRegisterForRemoteNotificationsWithDeviceId:fault:)]) {
            [self.pushReceiver didRegisterForRemoteNotificationsWithDeviceId:nil fault:fault];
        }
    }
#endif
}

-(void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    [DebLog log:@"MessagingService -> application:didFailToRegisterForRemoteNotificationsWithError: %@", err];
    if ([self.pushReceiver respondsToSelector:@selector(didFailToRegisterForRemoteNotificationsWithError:)]) {
        [self.pushReceiver didFailToRegisterForRemoteNotificationsWithError:err];
    }
}

-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [DebLog log:@"MessagingService -> application:didReceiveRemoteNotification: %@", userInfo];
    
#if 1 // -(void)didReceiveRemoteNotificationWithObject:(id)object headers:(NSDictionary *)headers;
    id object = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (![object isKindOfClass:NSString.class]) {
        if ([self.pushReceiver respondsToSelector:@selector(didReceiveRemoteNotificationWithObject:headers:)]) {
            [self.pushReceiver didReceiveRemoteNotificationWithObject:object headers:userInfo];
        }
        return;
    }
#endif
    
    NSString *pushMessage = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString *channelName = [userInfo objectForKey:@"{n}"];
    if (channelName && channelName.length) {
        
        BESubscription *subscription = [backendless.messaging.subscriptions get:channelName];
        if (subscription) {
            
            if (pushMessage && pushMessage.length) {
                
                NSData *data = [BEBase64 decode:pushMessage];
                BinaryStream *bytes = [BinaryStream streamWithStream:(char*)data.bytes andSize:(size_t)data.length];
                id message = [AMFSerializer deserializeFromBytes:bytes];
                if (message && [message isKindOfClass:Message.class]) {
                    [subscription.responder responseHandler:@[message]];
                }
                [DebLog log:@"MessagingService -> application:didReceiveRemoteNotification: (MESSAGE) %@", message];
            }
            else {
                [DebLog log:@"MessagingService -> application:didReceiveRemoteNotification: (!!! POLLING !!!)"];
                [backendless.messagingService pollMessages:channelName subscriptionId:subscription.subscriptionId responder:subscription.responder];
            }
        }
    }
    else {
        if ([self.pushReceiver respondsToSelector:@selector(didReceiveRemoteNotification:headers:)]) {
            NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:userInfo];
            [headers removeObjectForKey:@"aps"];
            [self.pushReceiver didReceiveRemoteNotification:pushMessage headers:headers];
        }
    }
}
#endif

#pragma mark -
#pragma mark Private Methods

// sync methods

-(NSString *)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    
    if (!channelName)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
#if !BACKENDLESS_VERSION_2_1_0
    NSArray *args = @[channelName, subscriptionOptions];
#else
    NSArray *args = @[channelName, subscriptionOptions, deviceRegistration];
#endif
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLLING_SUBSCRIBE args:args];
    
}

// async methods

-(void)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
#if !BACKENDLESS_VERSION_2_1_0
    NSArray *args = @[channelName, subscriptionOptions];
#else
    NSArray *args = @[channelName, subscriptionOptions, deviceRegistration];
#endif
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLLING_SUBSCRIBE args:args responder:responder];
}

// callbacks

-(id)onRegistering:(id)response {
    return (deviceRegistration.id = [NSString stringWithFormat:@"%@", response]);
}

-(id)onUnregistering:(id)response {
    
    NSNumber *result = (NSNumber *)response;
    if (result && [result boolValue]) deviceRegistration.id = nil;
    return response;
}

-(id)onSubscribe:(id)response {
    
    BESubscription *subscription = ((ResponseContext *)response).context;
    subscription.subscriptionId = (NSString *)((ResponseContext *)response).response;
    
    return [subscription autorelease];
}

@end
