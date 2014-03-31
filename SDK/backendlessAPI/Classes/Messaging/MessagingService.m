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

#define FAULT_NO_CHANNEL [Fault fault:@"Channel is not set for publishing"]
#define FAULT_NO_MESSAGE [Fault fault:@"Message is not set for publishing"]
#define FAULT_NO_MESSAGE_ID [Fault fault:@"Message ID is not set"]
#define FAULT_NO_SUBSCRIPTION_ID [Fault fault:@"Subscription ID is not set"]

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
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#else
- (NSString *)serialNumber;
#endif
@end


@implementation MessagingService
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#else
- (NSString *)serialNumber
{
    io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                                 
                                                                 IOServiceMatching("IOPlatformExpertDevice"));
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
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.management.DeviceRegistrationDto" mapped:[DeviceRegistration class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.Message" mapped:[Message class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.MessageStatus" mapped:[MessageStatus class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.PublishOptions" mapped:[PublishOptions class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.messaging.DeliveryOptions" mapped:[DeliveryOptions class]];
        deviceRegistration = [DeviceRegistration new];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        UIDevice *device = [UIDevice currentDevice];
        NSString *deviceId = [device.identifierForVendor UUIDString];
        deviceRegistration.deviceToken = device.name;
        deviceRegistration.deviceId = deviceId ? deviceId : @"c64c5320de162cc8f37a48e5c188d1621f1bd734";
        deviceRegistration.os = @"IOS";
        deviceRegistration.osVersion = device.systemVersion;
#else
        deviceRegistration.os = @"OSX";
        NSString *deviceId = [self serialNumber];
        deviceRegistration.deviceId = deviceId ? deviceId : @"c64c5320de162cc8f37a48e5c188d1621f1bd734";
#endif
        [DebLog log:@"MessagingService -> init: deviceToken = %@, deviceId = %@, os = %@, osVersion = %@", deviceRegistration.deviceToken, deviceRegistration.deviceId, deviceRegistration.os, deviceRegistration.osVersion];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MessagingService"];
    
    [deviceRegistration release];
	
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

// sync methods

//new

-(NSString *)registerDeviceWithTokenData:(NSData *)deviceToken error:(Fault **)fault
{
    id result = [self registerDeviceWithTokenData:deviceToken];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDeviceToken:(NSString *)deviceToken error:(Fault **)fault
{
    id result = [self registerDeviceToken:deviceToken];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDeviceExpiration:(NSDate *)expiration error:(Fault **)fault
{
    id result = [self registerDeviceExpiration:expiration];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDevice:(NSArray *)channels error:(Fault **)fault
{
    id result = [self registerDevice:channels];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration error:(Fault **)fault
{
    id result = [self registerDevice:channels expiration:expiration];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken error:(Fault **)fault
{
    id result = [self registerDevice:channels expiration:expiration token:deviceToken];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSString *)registerDeviceError:(Fault **)fault
{
    id result = [self registerDevice];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)getRegistrationsError:(Fault **)fault
{
    id result = [self getRegistrations];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)getRegistrations:(NSString *)deviceId error:(Fault **)fault
{
    id result = [self getRegistrations:deviceId];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)unregisterDeviceError:(Fault **)fault
{
    id result = [self unregisterDevice];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BOOL)unregisterDevice:(NSString *)deviceId error:(Fault **)fault
{
    id result = [self unregisterDevice:deviceId];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(MessageStatus *)publish:(NSString *)channelName message:(id)message error:(Fault **)fault
{
    id result = [self publish:channelName message:message];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions error:(Fault **)fault
{
    id result = [self publish:channelName message:message publishOptions:publishOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(MessageStatus *)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions error:(Fault **)fault
{
    id result = [self publish:channelName message:message deliveryOptions:deliveryOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(MessageStatus *)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions error:(Fault **)fault
{
    id result = [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:deliveryOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)cancel:(NSString *)messageId error:(Fault **)fault
{
    id result = [self cancel:messageId];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BESubscription *)subscribe:(NSString *)channelName error:(Fault **)fault
{
    id result = [self subscribe:channelName];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder error:(Fault **)fault
{
    id result = [self subscribe:channelName subscriptionResponder:subscriptionResponder];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponder:(id <IResponder>)subscriptionResponder subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault
{
    id result = [self subscribe:channelName subscriptionResponder:subscriptionResponder subscriptionOptions:subscriptionOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock error:(Fault **)fault
{
    id result = [self subscribe:channelName subscriptionResponse:subscriptionResponseBlock subscriptionError:subscriptionErrorBlock];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault
{
    id result = [self subscribe:channelName subscriptionResponse:subscriptionResponseBlock subscriptionError:subscriptionErrorBlock subscriptionOptions:subscriptionOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions error:(Fault **)fault
{
    id result = [self subscribe:subscription subscriptionOptions:subscriptionOptions];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId error:(Fault **)fault
{
    id result = [self pollMessages:channelName subscriptionId:subscriptionId];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to attachment:(NSArray *)attachment isHTML:(BOOL)isHTML error:(Fault **)fault
{
    id result = [self sendEmailWithSubject:subject body:body to:to attachment:attachment isHTML:isHTML];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

//deprecated
- (NSString *)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken {
    deviceRegistration.deviceToken = deviceToken;
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}
-(NSString *)registerDeviceWithTokenData:(NSData *)deviceToken
{
    NSString *token = [self deviceTokenAsString:deviceToken];
    return [self registerDeviceToken:token];
}
-(NSString *)registerDeviceToken:(NSString *)deviceToken {
    deviceRegistration.deviceToken = deviceToken;
    return [self registerDevice];
}

-(NSString *)registerDeviceExpiration:(NSDate *)expiration {
    
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSArray *)channels {
    
    deviceRegistration.channels = channels;
    return [self registerDevice];
}

-(NSString *)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration {
   
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    return [self registerDevice];
}

-(NSString *)registerDevice {
	
    [DebLog log:@"MessagingService -> deviceRegistration: %@", deviceRegistration];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceRegistration, nil];
    id result = [invoker invokeSync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_REGISTER_DEVICE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    return (deviceRegistration.id = [NSString stringWithFormat:@"%@", result]);
}

-(NSArray *)getRegistrations {
    return [self getRegistrations:deviceRegistration.deviceId];
}

-(NSArray *)getRegistrations:(NSString *)deviceId {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceId, nil];
    return [invoker invokeSync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_GET_REGISTRATIONS args:args];
}

-(id)unregisterDevice {
    return [self unregisterDevice:deviceRegistration.deviceId];
}

-(id)unregisterDevice:(NSString *)deviceId {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceId, nil];
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
    
    NSMutableArray *args = [NSMutableArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, message, publishOptions?publishOptions:[NSNull null], nil];
    if (deliveryOptions)
        [args addObject:deliveryOptions];
    
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_PUBLISH args:args];
}

-(id)cancel:(NSString *)messageId {
    
    if (!messageId)
        return [backendless throwFault:FAULT_NO_MESSAGE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, messageId, nil];
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

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock {
    return [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock]];
}

-(BESubscription *)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    return [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] subscriptionOptions:subscriptionOptions];
}

-(BESubscription *)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    
    if (!subscription)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    
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
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, subscriptionId, nil];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLL_MESSAGES args:args];
}

-(id)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to attachment:(NSArray *)attachment isHTML:(BOOL)isHTML
{
    BodyParts *bodyParts = [[BodyParts new] autorelease];
    if (isHTML) {
        bodyParts.htmlMessage = body;
    }
    else
    {
        bodyParts.textMessage = body;
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, subject, bodyParts, to, attachment, nil];
    return [invoker invokeSync:SERVER_MAIL_SERVICE_PATH method:METHOD_SEND_EMAIL args:args];
}
// async methods with responder

- (void)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken responder:(id<IResponder>)responder {
    deviceRegistration.deviceToken = deviceToken;
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    [self registerDeviceAsync:responder];
}
-(void)registerDeviceWithTokenData:(NSData *)deviceToken responder:(id<IResponder>)responder
{
    NSString *token = [self deviceTokenAsString:deviceToken];
    [self registerDeviceToken:token responder:responder];
}
-(void)registerDeviceToken:(NSString *)deviceToken responder:(id<IResponder>)responder {
    deviceRegistration.deviceToken = deviceToken;
    [self registerDeviceAsync:responder];
}

-(void)registerDeviceExpiration:(NSDate *)expiration responder:(id <IResponder>)responder {
    
    deviceRegistration.expiration = expiration;
    [self registerDeviceAsync:responder];
}

-(void)registerDevice:(NSArray *)channels responder:(id <IResponder>)responder {
    
    deviceRegistration.channels = channels;
    [self registerDeviceAsync:responder];
}

-(void)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration responder:(id <IResponder>)responder {
    
    deviceRegistration.channels = channels;
    deviceRegistration.expiration = expiration;
    [self registerDeviceAsync:responder];
}

-(void)registerDeviceAsync:(id<IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceRegistration, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onRegistering:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_REGISTER_DEVICE args:args responder:_responder];
}

-(void)getRegistrationsAsync:(id<IResponder>)responder {
    return [self getRegistrationsAsync:deviceRegistration.deviceId responder:responder];
}

-(void)getRegistrationsAsync:(NSString *)deviceId responder:(id<IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceId, nil];
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_GET_REGISTRATIONS args:args responder:responder];
}

-(void)unregisterDeviceAsync:(id<IResponder>)responder {
    return [self unregisterDeviceAsync:deviceRegistration.deviceId responder:responder];
}

-(void)unregisterDeviceAsync:(NSString *)deviceId responder:(id<IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, deviceId, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUnregistering:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_DEVICE_REGISTRATION_PATH method:METHOD_UNREGISTER_DEVICE args:args responder:_responder];
}

-(void)publish:(NSString *)channelName message:(id)message responder:(id <IResponder>)responder {
    [self publish:channelName message:message publishOptions:nil deliveryOptions:nil responder:responder];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions responder:(id <IResponder>)responder {
    [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:nil responder:responder];
}

-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions responder:(id <IResponder>)responder {
    [self publish:channelName message:message publishOptions:nil deliveryOptions:deliveryOptions responder:responder];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions responder:(id <IResponder>)responder {
    
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    
    if (!message) 
        return [responder errorHandler:FAULT_NO_MESSAGE];
    
    NSMutableArray *args = [NSMutableArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, message, publishOptions?publishOptions:[NSNull null], nil];
    if (deliveryOptions)
        [args addObject:deliveryOptions];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_PUBLISH args:args responder:responder];
}

-(void)cancel:(NSString *)messageId responder:(id <IResponder>)responder {
    
    if (!messageId) 
        return [responder errorHandler:FAULT_NO_MESSAGE_ID];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, messageId, nil];
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
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, subscriptionId, nil];
    [invoker invokeAsync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLL_MESSAGES args:args responder:responder];
}

-(void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to attachment:(NSArray *)attachment isHTML:(BOOL)isHTML responder:(id<IResponder>)responder
{
    BodyParts *bodyParts = [[BodyParts new] autorelease];
    if (isHTML) {
        bodyParts.htmlMessage = body;
    }
    else
    {
        bodyParts.textMessage = body;
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, subject, bodyParts, to, attachment, nil];
    [invoker invokeAsync:SERVER_MAIL_SERVICE_PATH method:METHOD_SEND_EMAIL args:args responder:responder];
}
// async methods with block-base callbacks

-(void)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration token:(NSString *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDevice:channels expiration:expiration token:deviceToken responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)registerDeviceWithTokenData:(NSData *)deviceToken response:(void (^)(NSString *))responseBlock error:(void (^)(Fault *))errorBlock
{
    NSString *token = [self deviceTokenAsString:deviceToken];
    [self registerDeviceToken:token responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)registerDeviceToken:(NSString *)deviceToken response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDeviceToken:deviceToken responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)registerDeviceExpiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDeviceExpiration:expiration responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)registerDevice:(NSArray *)channels response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDevice:channels responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)registerDevice:(NSArray *)channels expiration:(NSDate *)expiration response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDevice:channels expiration:expiration responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)registerDeviceAsync:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registerDeviceAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getRegistrationsAsync:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getRegistrationsAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getRegistrationsAsync:(NSString *)deviceId response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self getRegistrationsAsync:deviceId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)unregisterDeviceAsync:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self unregisterDeviceAsync:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)unregisterDeviceAsync:(NSString *)deviceId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self unregisterDeviceAsync:deviceId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)publish:(NSString *)channelName message:(id)message response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message publishOptions:publishOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)publish:(NSString *)channelName message:(id)message deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  publish:channelName message:message deliveryOptions:deliveryOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)publish:(NSString *)channelName message:(id)message publishOptions:(PublishOptions *)publishOptions deliveryOptions:(DeliveryOptions *)deliveryOptions response:(void(^)(MessageStatus *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self publish:channelName message:message publishOptions:publishOptions deliveryOptions:deliveryOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)cancel:(NSString *)messageId response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self cancel:messageId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(NSString *)channelName subscriptionResponse:(void(^)(NSArray *))subscriptionResponseBlock subscriptionError:(void(^)(Fault *))subscriptionErrorBlock subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self subscribe:channelName subscriptionResponder:[ResponderBlocksContext responderBlocksContext:subscriptionResponseBlock error:subscriptionErrorBlock] subscriptionOptions:subscriptionOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)subscribe:(BESubscription *)subscription subscriptionOptions:(SubscriptionOptions *)subscriptionOptions response:(void(^)(BESubscription *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self  subscribe:subscription subscriptionOptions:subscriptionOptions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)pollMessages:(NSString *)channelName subscriptionId:(NSString *)subscriptionId response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self pollMessages:channelName subscriptionId:subscriptionId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)sendEmailWithSubject:(NSString *)subject body:(NSString *)body to:(NSArray *)to attachment:(NSArray *)attachment isHTML:(BOOL)isHTML response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self sendEmailWithSubject:subject body:body to:to attachment:attachment isHTML:isHTML responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
#pragma mark -
#pragma mark Private Methods

// sync methods

-(NSString *)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions {
    
    if (!channelName)
        return [backendless throwFault:FAULT_NO_CHANNEL];
    
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, subscriptionOptions, nil];
    return [invoker invokeSync:SERVER_MESSAGING_SERVICE_PATH method:METHOD_POLLING_SUBSCRIBE args:args];
    
}

// async methods

-(void)subscribeForPollingAccess:(NSString *)channelName subscriptionOptions:(SubscriptionOptions *)subscriptionOptions responder:(id <IResponder>)responder {
    
    if (!channelName)
        return [responder errorHandler:FAULT_NO_CHANNEL];
    
    if (!subscriptionOptions)
        subscriptionOptions = [SubscriptionOptions new];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, channelName, subscriptionOptions, nil];
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
