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

#if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
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

#define DEFAULT_POLLING_INTERVAL 5

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
// utils
-(NSString *)serialNumber;
@end

@implementation MessagingService

@synthesize pollingFrequencySec;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(NSString *)serialNumber {
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
            [self unregisterDevice:[[UIDevice currentDevice].identifierForVendor UUIDString] response:nil error:nil];
        });
    }
    return UUID;
}

#else // OSX
-(NSString *)serialNumber {
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;
    if (platformExpert) {
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, CFSTR(kIOPlatformSerialNumberKey), kCFAllocatorDefault, 0);
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
    if (self = [super init]) {
        self.pollingFrequencySec = DEFAULT_POLLING_INTERVAL;
        _subscriptions = [HashMap new];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.management.DeviceRegistrationDto" mapped:[DeviceRegistration class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.Message" mapped:[Message class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.messaging.MessageStatus" mapped:[MessageStatus class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.PublishOptions" mapped:[PublishOptions class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.messaging.DeliveryOptions" mapped:[DeliveryOptions class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.mail.BodyParts" mapped:[BodyParts class]];
        deviceRegistration = [DeviceRegistration new];
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIDevice *device = [UIDevice currentDevice];
        // use generated UUID which is saved in keychain with bundleId as key
        NSString *deviceId = [self serialNumber];
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

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
-(void)attachmentProcessing:(UNNotificationRequest *_Nonnull)request withContentHandler:(void (^_Nonnull)(UNNotificationContent *_Nonnull))contentHandler {    
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
#endif

// sync methods with fault return (as exception)

-(NSString *)registerDevice:(NSData *)deviceToken {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = @[DEFAULT_CHANNEL_NAME];
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = @[DEFAULT_CHANNEL_NAME];
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration {
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
    deviceRegistration.id = [NSString stringWithFormat:@"%@", result];
    return deviceRegistration.deviceId;
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
    return [self subscribe:[BESubscription subscription:channelName responder:nil] subscriptionOptions:nil];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock {
    return [self subscribe:[BESubscription subscription:channelName responder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]] subscriptionOptions:nil];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    return [self subscribe:[BESubscription subscription:channelName responder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]] subscriptionOptions:subscriptionOptions];
}

-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    if (!subscription)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    subscription.deliveryMethod = [subscriptionOptions valDeliveryMethod];
    subscriptionOptions.deviceId = deviceRegistration.deviceId;
    id result = [self subscribeForPollingAccess:subscription.channelName subscriptionOptions:subscriptionOptions];
    if ([result isKindOfClass:[Fault class]])
        return result;
    subscription.subscriptionId = result;
    [subscription startPolling];
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

// async methods with block-based callbacks

-(void)registerDeviceAsync:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
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

-(void)registerDevice:(NSData *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = @[DEFAULT_CHANNEL_NAME];
    [self registerDeviceAsync:responseBlock error:errorBlock];
}

-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    [self registerDeviceAsync:responseBlock error:errorBlock];
}

-(void)registerDevice:(NSData *)deviceToken expiration:(NSDate *)expiration response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = @[DEFAULT_CHANNEL_NAME];
    deviceRegistration.expiration = expiration;
    [self registerDeviceAsync:responseBlock error:errorBlock];
}

-(void)registerDevice:(NSData *)deviceToken channels:(NSArray<NSString *> *)channels expiration:(NSDate *)expiration response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock {
    deviceRegistration.deviceToken = [self deviceTokenAsString:deviceToken];
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    [self registerDeviceAsync:responseBlock error:errorBlock];
}

-(void)getRegistration:(NSString *)deviceId response:(void(^)(DeviceRegistration *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!deviceId)
        return [responder errorHandler:FAULT_NO_DEVICE_ID];
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_GET_REGISTRATIONS args:args responder:responder];
}

-(void)unregisterDevice:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self unregisterDevice:deviceRegistration.deviceId response:responseBlock error:errorBlock];
}

-(void)unregisterDevice:(NSString *)deviceId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!deviceId)
        return [responder errorHandler:FAULT_NO_DEVICE_ID];
    NSArray *args = [NSArray arrayWithObjects:deviceId, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUnregistering:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_UNREGISTER_DEVICE args:args responder:_responder];
}

-(void)publish:(NSString *)channelName message:(id)message response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message publishOptions:nil deliveryOptions:nil response:responseBlock error:errorBlock];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:nil response:responseBlock error:errorBlock];
}

-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message publishOptions:nil deliveryOptions:deliveryOptions response:responseBlock error:errorBlock];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    if (!message)
        return [responder errorHandler:FAULT_NO_MESSAGE];
    NSMutableArray *args = [NSMutableArray arrayWithObjects:channelName, message, publishOptions?publishOptions:[NSNull null], nil];
    if (deliveryOptions)
        [args addObject:deliveryOptions];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_PUBLISH args:args responder:responder];
}

-(void)cancel:(NSString *)messageId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!messageId)
        return [responder errorHandler:FAULT_NO_MESSAGE_ID];
    NSArray *args = [NSArray arrayWithObjects:messageId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_CANCEL args:args responder:responder];
}

-(void)subscribe:(NSString *)channelName response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  subscribe:[BESubscription subscription:channelName responder:nil]
 subscriptionOptions:nil
           responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  subscribe:[BESubscription subscription:channelName responder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]]
 subscriptionOptions:nil
           responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray<Message*> *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  subscribe:[BESubscription subscription:channelName responder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]]
 subscriptionOptions:subscriptionOptions
           responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    if (!subscription)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    subscription.deliveryMethod = [subscriptionOptions valDeliveryMethod];
    subscriptionOptions.deviceId = deviceRegistration.deviceId;
    [subscription startPolling];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onSubscribe:) selErrorHandler:nil];
    _responder.context = [subscription retain];
    _responder.chained = responder;
    [self subscribeForPollingAccess:subscription.channelName subscriptionOptions:subscriptionOptions responder:_responder];
}

-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    if (!subscriptionId)
        return [responder errorHandler:FAULT_NO_SUBSCRIPTION_ID];
    NSArray *args = [NSArray arrayWithObjects:channelName, subscriptionId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLL_MESSAGES args:args responder:responder];
}

-(void)sendTextEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendEmail:subject body:[BodyParts bodyText:messageBody html:nil] to:recipients attachment:nil response:responseBlock error:errorBlock];
}

-(void)sendHTMLEmail:(NSString *)subject body:(NSString *)messageBody to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendEmail:subject body:[BodyParts bodyText:nil html:messageBody] to:recipients attachment:nil response:responseBlock error:errorBlock];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self sendEmail:subject body:bodyParts to:recipients attachment:nil response:responseBlock error:errorBlock];
}

-(void)sendEmail:(NSString *)subject body:(BodyParts *)bodyParts to:(NSArray<NSString*> *)recipients attachment:(NSArray *)attachments response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!bodyParts || ![bodyParts isBody])
        return [responder errorHandler:FAULT_NO_BODY];
    if (!recipients || !recipients.count)
        return [responder errorHandler:FAULT_NO_RECIPIENT];
    NSArray *args = @[(subject)?subject:@"", bodyParts, recipients, (attachments)?attachments:@[]];
    [invoker invokeAsync:SERVER_MAIL_SERVICE_PATH method:METHOD_SEND_EMAIL args:args responder:responder];
}

-(void)getMessageStatus:(NSString*)messageId response:(void(^)(MessageStatus*))responseBlock error:(void(^)(Fault *))errorBlock {
    Responder *chainedResponder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!messageId)
        return [chainedResponder errorHandler:FAULT_NO_MESSAGE_ID];
    NSMutableArray *args = [NSMutableArray arrayWithObjects:messageId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_MESSAGE_STATUS args:args responder:chainedResponder];
}

#pragma mark -
#pragma mark Private Methods

// sync
-(NSString *)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    if (!channelName)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
    NSArray *args = @[channelName, subscriptionOptions];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLLING_SUBSCRIBE args:args];
}

// async
-(void)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
    NSArray *args = @[channelName, subscriptionOptions];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLLING_SUBSCRIBE args:args responder:responder];
}

// callbacks

-(id)onRegistering:(id)response {
    deviceRegistration.id = [NSString stringWithFormat:@"%@", response];
    return deviceRegistration.deviceId;
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
