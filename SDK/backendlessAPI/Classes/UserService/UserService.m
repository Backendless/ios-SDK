//
//  UserService.m
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

#import "UserService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "HashMap.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessUser.h"
#import "UserProperty.h"
#import "AMFSerializer.h"`
#import "AuthorizationException.h"
#import "RTClient.h"

#define FAULT_NO_USER_CREDENTIALS [Fault fault:@"Login or password is missing or null" detail:@"Login or password is missing or null" faultCode:@"3006"]
#define FAULT_NO_USER [Fault fault:@"User is missing or null" detail:@"User is missing or null" faultCode:@"3900"]
#define FAULT_NO_USER_ID [Fault fault:@"objectId is missing or null" detail:@"objectId is missing or null" faultCode:@"3901"]
#define FAULT_NO_USER_ROLE [Fault fault:@"user role is missing or null" detail:@"user role is missing or null" faultCode:@"3902"]
#define FAULT_NO_USER_EMAIL [Fault fault:@"user email is missing or null" detail:@"user email is missing or null" faultCode:@"3903"]
#define FAULT_USER_IS_NOT_LOGGED_IN [Fault fault:@"user is not logged in" detail:@"user is not logged in" faultCode:@"3904"]

// PERSISTENT USER
static NSString *PERSIST_USER_FILE_NAME = @"user.bin";
// SERVICE NAME
static NSString *SERVER_USER_SERVICE_PATH = @"com.backendless.services.users.UserService";
// METHOD NAMES
static NSString *METHOD_REGISTER = @"register";
static NSString *METHOD_UPDATE = @"update";
static NSString *METHOD_LOGIN = @"login";
static NSString *METHOD_LOGOUT = @"logout";
static NSString *METHOD_RESTORE_PASSWORD = @"restorePassword";
static NSString *METHOD_DESCRIBE_USER_CLASS = @"describeUserClass";
static NSString *METHOD_GET_USER_ROLES = @"getUserRoles";
static NSString *METHOD_IS_VALID_USER_TOKEN = @"isValidUserToken";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK = @"getFacebookServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_TWITTER = @"getTwitterServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_GOOGLEPLUS = @"getGooglePlusServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK_SDK = @"loginWithFacebook";
static NSString *METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK = @"loginWithGooglePlus";
static NSString *METHOD_USER_LOGIN_WITH_TWITTER_SDK = @"loginWithTwitter";
static NSString *METHOD_RESEND_EMAIL_CONFIRMATION = @"resendEmailConfirmation";

@interface UserService ()
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property BOOL iOS9above;
#endif

// callbacks
-(id)registerResponse:(ResponseContext *)response;
-(id)registerError:(id)error;
-(id)easyLoginResponder:(id)response;
-(id)easyLoginError:(Fault *)fault;
-(id)onLogin:(id)response;
-(id)onUpdate:(ResponseContext *)response;
-(id)onLogout:(id)response;
-(id)onLogoutError:(Fault *)fault;

@end

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if _USE_SAFARI_VC_
@interface UserService (SafariVC) <SFSafariViewControllerDelegate>
-(UIViewController *)getCurrentViewController;
@end
#endif
#endif

@implementation UserService

-(id)init {
    if (self = [super init]) {
        self.currentUser = nil;
        _isStayLoggedIn = NO;
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.UserProperty" mapped:[UserProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.AbstractProperty" mapped:[AbstractProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.exceptions.security.AuthorizationException" mapped:[AuthorizationException class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.exceptions.user.UserServiceException" mapped:[AuthorizationException class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        self.iOS9above = [[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:openURL:options:)];
#endif
    }
    return self;
}

-(BackendlessUser *)castFromDictionary:(id)castObject {
    BackendlessUser *castedUser = nil;
    if ([castObject isKindOfClass:[BackendlessUser class]]) {
        castedUser = (BackendlessUser *)castObject;
    }
    else if ([castObject isKindOfClass:[NSDictionary class]]) {
        BackendlessUser *user = [BackendlessUser new];
        for (NSString *key in [castObject allKeys]) {
            id value = [castObject valueForKey:key];
            if (![value isEqual:[NSNull null]]) {
                [user setProperty:key object:value];
            }
            else {
                [user setProperty:key object:nil];
            }
        }
        castedUser = user;
    }
    return castedUser;
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)setStayLoggedIn:(BOOL)value {
    if (value == _isStayLoggedIn)
        return YES;
    return (_isStayLoggedIn = value) ? [self setPersistentUser] : [self resetPersistentUser];
}

// sync methods with fault return (as exception)

-(BackendlessUser *)registerUser:(BackendlessUser *)user {
    if (!user)
        return [backendless throwFault:FAULT_NO_USER];
    if (![user getProperties])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    return [self castFromDictionary:[invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args]];
}

-(BackendlessUser *)update:(BackendlessUser *)user {
    if (!user)
        return [backendless throwFault:FAULT_NO_USER];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    if ([result isKindOfClass:[BackendlessUser class]]) {
        user = result;
    }
    else {
        [user setProperties:result];
    }
    if (_isStayLoggedIn && self.currentUser && [user.objectId isEqualToString:self.currentUser.objectId]) {
        [self updateCurrentUser:result];
    }
    return user;
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password {
    if (!login || !password || ![login length] || ![password length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:login, password, nil];
    self.currentUser = [self castFromDictionary:[invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args]];
    if (self.currentUser.getUserToken) {
        [backendless.headers setValue:self.currentUser.getUserToken forKey:BACKENDLESS_USER_TOKEN];
    }
    else {
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    }
    
    [self setPersistentUser];
    return self.currentUser;
}

-(BackendlessUser *)findById:(NSString *)objectId {
    return [[backendless.data of:[BackendlessUser class]] findById:objectId];
}

-(id)logout {
    BOOL throwException = invoker.throwException;
    invoker.throwException = NO;
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:@[]];
    invoker.throwException = throwException;
    if ([result isKindOfClass:[Fault class]]) {
        [self onLogoutError:result];
        if (throwException)
            @throw result;
        return result;
    }
    return [self onLogout:result];
}

-(NSNumber *)isValidUserToken {
    NSString *userToken = [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
    if (!self.currentUser || !userToken)
        return @(NO);
    NSArray *args = @[userToken];
    BOOL throwException = invoker.throwException;
    invoker.throwException = NO;
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args];
    invoker.throwException = throwException;
    if ([result isKindOfClass:[Fault class]]) {
        Fault *fault = (Fault *)result;
        if ([fault.faultCode isEqualToString:@"3048"]) {
            [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
        }
        if (throwException)
            @throw result;
    }
    return result;
}

-(id)restorePassword:(NSString *)login {
    if (!login||!login.length)
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:login, nil];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_RESTORE_PASSWORD args:args];
}

-(NSArray<UserProperty*> *)describeUserClass {
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_DESCRIBE_USER_CLASS args:@[]];
}

-(NSArray<NSString*> *)getUserRoles {
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:@[]];
}

-(BackendlessUser *)loginWithFacebookSDK:(NSString *)userId tokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate fieldsMapping:(id)fieldsMapping {
    NSArray *args = @[userId, tokenString, expirationDate, @[], (NSDictionary<NSString *, NSString*> *)fieldsMapping?fieldsMapping:@{}];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(BackendlessUser *)loginWithGoogleSDK:(NSString *)idToken accessToken:(NSString *)accessToken {
    if (!idToken||!idToken.length||!accessToken||!accessToken.length)
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = @[idToken, accessToken, @[], @{}];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(BackendlessUser *)loginWithTwitterSDK:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret fieldsMapping:(id)fieldsMapping {
    if (!authToken||!authToken.length||!authTokenSecret||!authTokenSecret.length)
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = @[authToken, authTokenSecret, (NSDictionary<NSString *, NSString*> *)fieldsMapping?fieldsMapping:@{}];    
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(id)resendEmailConfirmation:(NSString *)email {
    if (!email||!email.length)
        return [backendless throwFault:FAULT_NO_USER_EMAIL];
    NSArray *args = @[email];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_RESEND_EMAIL_CONFIRMATION args:args];
}

// async methods with block-based callbacks

-(void)registerUser:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (!user)
        [backendless throwFault:FAULT_NO_USER];
    if (![user getProperties])
        [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    
    void(^wrappedBlock)(NSDictionary *) = ^(NSDictionary *regUserDict) {
        responseBlock([self castFromDictionary:regUserDict]);
    };
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args responder:[ResponderBlocksContext responderBlocksContext:wrappedBlock error:errorBlock]];
}

-(void)update:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    id <IResponder> responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!user)
        return [responder errorHandler:FAULT_NO_USER];
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUpdate:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = user;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args responder:_responder];
}

-(void)login:(NSString *)login password:(NSString *)password response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    if (!login || !password || ![login length] || ![password length])
        [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:login, password, nil];
    Responder *responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args responder:_responder];
}

-(void)findById:(NSString *)objectId response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [[backendless.data of:[BackendlessUser class]] findById:objectId response:responseBlock error:errorBlock];
}

-(void)logout:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id <IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogout:) selErrorHandler:@selector(onLogoutError:)];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:@[] responder:_responder];
}

-(void)isValidUserToken:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    id <IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSString *userToken = [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
    if (!self.currentUser || !userToken) {
        [responder responseHandler:@(NO)];
        return;
    }
    NSArray *args = @[userToken];
    Responder *_responder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(onValidUserTokenFault:)];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args responder:_responder];
}

-(void)restorePassword:(NSString *)login response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!login||!login.length)
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:login, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_RESTORE_PASSWORD args:args responder:responder];
}

-(void)describeUserClass:(void(^)(NSArray<UserProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_DESCRIBE_USER_CLASS args:@[] responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getUserRoles:(void (^)(NSArray<NSString*> *))responseBlock error:(void (^)(Fault *))errorBlock {
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:@[] responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithFacebookSDK:(NSString *)userId tokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate fieldsMapping:(id)fieldsMapping response:(void (^)(BackendlessUser *))responseBlock error:(void (^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    NSArray *args = @[userId, tokenString, expirationDate, @[], (NSDictionary<NSString *, NSString*> *)fieldsMapping?fieldsMapping:@{}];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args responder:_responder];
}

-(void)loginWithGoogleSDK:(NSString *)idToken accessToken:(NSString *)accessToken response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!idToken||!idToken.length||!accessToken||!accessToken.length)
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = @[idToken, accessToken, @[], @{}];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK args:args responder:_responder];
}

-(void)loginWithTwitterSDK:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret fieldsMapping:(id)fieldsMapping response:(void (^)(BackendlessUser *))responseBlock error:(void (^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!authToken||!authToken.length||!authTokenSecret||!authTokenSecret.length) {
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    }
    NSArray *args = @[authToken, authTokenSecret, (NSDictionary<NSString *, NSString*> *)fieldsMapping?fieldsMapping:@{}];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER_SDK args:args responder:_responder];
}

-(void)resendEmailConfirmation:(NSString *)email response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    if (!email||!email.length)
        return [responder errorHandler:FAULT_NO_USER_EMAIL];
    NSArray *args = @[email];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_RESEND_EMAIL_CONFIRMATION args:args responder:responder];
}

// methods of social easy logins
// Twitter
-(BackendlessUser *)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    id<IResponder>responder = [ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER args:args responder:_responder];
}

// utilites

-(BackendlessUser *)handleOpenURL:(NSURL *)url {
    [DebLog log:@"UserService -> handleOpenURL: url = '%@'", url];
    NSString *scheme = [[NSString stringWithFormat:@"backendless%@", backendless.appID] uppercaseString];
    if (![[url.scheme uppercaseString] isEqualToString:scheme]) {
        [DebLog logY:@"UserService -> handleOpenURL: SCHEME IS WRONG = %@", url.scheme];
        return nil;
    }
    NSString *absoluteString = [url.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://", url.scheme] withString:@""];
    NSString *json = [absoluteString stringByRemovingPercentEncoding];
    if (!json) {
        json = [absoluteString stringByReplacingPercentEscapesUsingEncoding:NSISOLatin1StringEncoding];
    }
    NSString *substr;
    NSUInteger index = json?json.length:0;
    while (index) {
        substr = [json substringFromIndex:--index];
        if ([substr isEqualToString:@"}"])
            break;
        json = [json substringToIndex:index];
    };
    if (!json) {
        [DebLog logY:@"UserService -> handleOpenURL: JSON IS BROKEN"];
        return nil;
    }
    [DebLog log:@"UserService -> handleOpenURL: JSONObject = '%@'", json];
    @try {
        NSError *error = nil;
        id userData = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding: NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
            [DebLog logY:@"UserService -> handleOpenURL: ERROR = %@", error];
            return nil;
        }
        [DebLog log:@"UserService -> handleOpenURL: userData = '%@'", userData];
        return [self onLogin:userData];
    }
    @catch (NSException *exception) {
        [DebLog logY:@"UserService -> handleOpenURL: EXCEPTION = %@", exception];
        return nil;
    }
}

-(void)handleOpenURL:(NSURL *)url completion:(void(^)(BackendlessUser *))completion {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if _USE_SAFARI_VC_
    if (self.iOS9above) {
        __block BackendlessUser *user = [self handleOpenURL:url];
        [backendless.safariVC
         dismissViewControllerAnimated:true
         completion:^(void) {
             if (completion) {
                 completion(user);
             }
         }];
        return;
    }
#endif
#endif
    if (completion) {
        completion([self handleOpenURL:url]);
    }
}

// persistent user

-(BOOL)getPersistentUser {
    id obj = [AMFSerializer deserializeFromFile:PERSIST_USER_FILE_NAME];
    self.currentUser = obj ? [[BackendlessUser alloc] initWithProperties:obj] : nil;
    _isStayLoggedIn = (BOOL)self.currentUser;
    if (_isStayLoggedIn && self.currentUser.getUserToken) {
        [backendless.headers setValue:self.currentUser.getUserToken forKey:BACKENDLESS_USER_TOKEN];
    }
    else {
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    }
    return _isStayLoggedIn;
}

-(BOOL)setPersistentUser {
    if (self.currentUser) {
        [rtClient userLoggedInWithToken:self.currentUser.getUserToken];
        if (_isStayLoggedIn) {
            NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[self.currentUser getProperties]];
            NSString *userToken = [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
            if (userToken) {
                [properties setValue:userToken forKey:BACKENDLESS_USER_TOKEN];
            }
            return [AMFSerializer serializeToFile:properties fileName:PERSIST_USER_FILE_NAME];
        }
    }
    return NO;
}

-(BOOL)resetPersistentUser {
    return [AMFSerializer serializeToFile:nil fileName:PERSIST_USER_FILE_NAME];
    [rtClient userLoggedInWithToken:nil];
}

#pragma mark -
#pragma mark Private Methods

// callbacks

-(id)registerError:(id)error {
    [DebLog log:@"UserService -> registerError: %@", error];
    return error;
}

-(id)registerResponse:(ResponseContext *)response {
    [DebLog log:@"UserService -> registerResponse: %@", response];
    BackendlessUser *user = response.context;
    [user setProperties:response.response];
    return user;
}

-(id)easyLoginError:(Fault *)fault {
    [DebLog log:@"UserService -> easyLoginError: %@", fault.detail];
    return fault;
}

-(id)easyLoginResponder:(id)response {
    NSURL *url = [NSURL URLWithString:response];
    [DebLog log:@"UserService -> easyLoginResponder: '%@' -> '%@'", response, url];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if _USE_SAFARI_VC_
    if (self.iOS9above) {
        [DebLog log:@"UserService -> easyLoginResponder: (**************** SAFARI VC *************************)"];
        backendless.safariVC = [[SFSafariViewController alloc] initWithURL:url];
        backendless.safariVC.delegate = self;
        UIViewController *vc = [self getCurrentViewController];
        [vc showViewController:backendless.safariVC sender:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:url];
    }
#else
    [[UIApplication sharedApplication] openURL:url];
#endif
#endif
    return @(YES);
}

-(id)onLogin:(id)response {
    if ([response isKindOfClass:[BackendlessUser class]]) {
        self.currentUser = response;
    }
    else {
        NSDictionary *props = (NSDictionary *)response;
        (self.currentUser) ? [self.currentUser setProperties:props] : (self.currentUser = [[BackendlessUser alloc] initWithProperties:props]);
    }
    if (self.currentUser.getUserToken)
        [backendless.headers setValue:self.currentUser.getUserToken forKey:BACKENDLESS_USER_TOKEN];
    else
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    [self setPersistentUser];
    return self.currentUser;
}

-(void)updateCurrentUser:(id)response {
    if ([response isKindOfClass:[BackendlessUser class]]) {
        self.currentUser = response;
    }
    else {
        NSDictionary *props = (NSDictionary *)response;
        (self.currentUser) ? [self.currentUser setProperties:props] : (self.currentUser = [[BackendlessUser alloc] initWithProperties:props]);
    }
    [self setPersistentUser];
}

-(id)onUpdate:(ResponseContext *)response {
    [DebLog log:@"UserService -> onUpdate: %@", response];
    BackendlessUser *user = response.context;
    id result = response.response;
    if ([result isKindOfClass:[BackendlessUser class]]) {
        user = result;
    }
    else {
        [user setProperties:result];
    }
    
    if (_isStayLoggedIn && self.currentUser && [user.objectId isEqualToString:self.currentUser.objectId]) {
        [self updateCurrentUser:result];
    }
    return user;
}

-(id)onLogout:(id)response {
    [DebLog log:@"UserService -> onLogout: %@", response];
    if (self.currentUser) {
        self.currentUser = nil;
    }
    [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    [self resetPersistentUser];
    return response;
}

-(id)onLogoutError:(Fault *)fault {
    [DebLog log:@"UserService -> onLogoutError: %@", fault];
    NSArray *faultCodes = @[@"3023", @"3064", @"3090", @"3091"];
    for (NSString *code in faultCodes) {
        if ([fault.faultCode isEqualToString:code]) {
            return [self onLogout:fault];
        }
    }
    return fault;
}

-(id)onValidUserTokenFault:(Fault *)fault {
    if ([fault.faultCode isEqualToString:@"3048"]) {
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    }
    return fault;
}

@end


#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#if _USE_SAFARI_VC_
@implementation UserService (SafariVC)

-(UIViewController *)getCurrentViewController {
    UIViewController *WindowRootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIViewController *currentViewController = [self findTopViewController:WindowRootVC];
    return currentViewController;
}

-(UIViewController *)findTopViewController:(UIViewController *)inController {
    if ([inController isKindOfClass:[UITabBarController class]]) {
        return [self findTopViewController:[(UITabBarController *)inController selectedViewController]];
    }
    else if ([inController isKindOfClass:[UINavigationController class]]) {
        return [self findTopViewController:[(UINavigationController *)inController visibleViewController]];
    }
    else if ([inController isKindOfClass:[UIViewController class]]) {
        return inController;
    }
    else {
        [DebLog log:@"UserService -> findTopViewController: Unhandled ViewController class : %@", inController.class];
        return nil;
    }
}

-(void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [controller dismissViewControllerAnimated:true completion: nil];
}

@end
#endif
#endif
