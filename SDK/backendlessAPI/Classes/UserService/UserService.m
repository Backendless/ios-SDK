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

#define PERSIST_CURRENTUSER_OFF 0
#define REPEAT_EASYLOGIN_ON 0

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import "UserService.h"
#import "DEBUG.h"
#import "Types.h"
#import "Responder.h"
#import "HashMap.h"
#import "Backendless.h"
#import "Invoker.h"
#import "BackendlessUser.h"
#import "UserProperty.h"
#import "AMFSerializer.h"
#import "AuthorizationException.h"

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
static NSString *METHOD_FIND_BY_ID = @"findById";
static NSString *METHOD_LOGOUT = @"logout";
static NSString *METHOD_RESTORE_PASSWORD = @"restorePassword";
static NSString *METHOD_DESCRIBE_USER_CLASS = @"describeUserClass";
static NSString *METHOD_ASSIGN_ROLE = @"assignRole";
static NSString *METHOD_UNASSIGN_ROLE = @"unassignRole";
static NSString *METHOD_GET_USER_ROLES = @"getUserRoles";
static NSString *METHOD_IS_VALID_USER_TOKEN = @"isValidUserToken";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK = @"getFacebookServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_TWITTER = @"getTwitterServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_GOOGLEPLUS = @"getGooglePlusServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK_SDK = @"loginWithFacebook";
static NSString *METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK = @"loginWithGooglePlus";
static NSString *METHOD_RESEND_EMAIL_CONFIRMATION = @"resendEmailConfirmation";


@interface UserService ()
#if REPEAT_EASYLOGIN_ON
@property (strong, nonatomic) NSString *easyLoginUrl;
#endif
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
@property BOOL iOS9above;
#endif
// sync
-(id)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping;
// async
-(void)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder;
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
	if ( (self=[super init]) ) {

#if REPEAT_EASYLOGIN_ON
        _easyLoginUrl = nil;
#endif
        _currentUser = nil;
        _isStayLoggedIn = NO;

        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.UserProperty" mapped:[UserProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.AbstractProperty" mapped:[AbstractProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.exceptions.security.AuthorizationException" mapped:[AuthorizationException class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.exceptions.user.UserServiceException" mapped:[AuthorizationException class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.geo.model.GeoPoint" mapped:[GeoPoint class]];
#if !_IS_USERS_CLASS_
        [[Types sharedInstance] addClientClassMapping:@"Users" mapped:[BackendlessUser class]];
#endif
        
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
        self.iOS9above = [[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:openURL:options:)];
#endif
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UserService"];
#if REPEAT_EASYLOGIN_ON
    [_easyLoginUrl release];
#endif
    
    [_currentUser release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Public Methods

-(BOOL)setStayLoggedIn:(BOOL)value {
    
    if (value == _isStayLoggedIn)
        return YES;
    
    return (_isStayLoggedIn = value) ? [self setPersistentUser] : [self resetPersistentUser];
}

// sync methods with fault option

#if OLD_ASYNC_WITH_FAULT

-(BackendlessUser *)registering:(BackendlessUser *)user error:(Fault **)fault {
    
    id result = [self registering:user];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessUser *)update:(BackendlessUser *)user error:(Fault **)fault {
    
    id result = [self update:user];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password error:(Fault **)fault {
    
    id result = [self login:login password:password];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)logoutError:(Fault **)fault {
    
    id result = [self logout];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(NSNumber *)isValidUserTokenError:(Fault **)fault {
    
    id result = [self isValidUserToken];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    return result;
}

-(BOOL)restorePassword:(NSString *)login error:(Fault **)fault {
    
    id result = [self restorePassword:login];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(NSArray *)describeUserClassError:(Fault **)fault {
    
    id result = [self describeUserClass];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(BOOL)user:(NSString *)user assignRole:(NSString *)role error:(Fault **)fault {
    
    id result = [self user:user assignRole:role];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BOOL)user:(NSString *)user unassignRole:(NSString *)role error:(Fault **)fault {
    
    id result = [self user:user unassignRole:role];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return NO;
        }
        (*fault) = result;
        return NO;
    }
    return YES;
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping error:(Fault **)fault {
    
    id result = [self loginWithFacebookSDK:session user:user fieldsMapping:fieldsMapping];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}

-(NSArray *)getUserRolesError:(Fault **)fault {
    
    id result = [self getUserRoles];
    if ([result isKindOfClass:[Fault class]]) {
        if (!fault) {
            return nil;
        }
        (*fault) = result;
        return nil;
    }
    return result;
}
#else

#if 0 // wrapper for work without exception

id result = nil;
@try {
}
@catch (Fault *fault) {
    result = fault;
}
@finally {
    if ([result isKindOfClass:Fault.class]) {
        if (fault)(*fault) = result;
        return nil;
    }
    return result;
}

#endif

-(BackendlessUser *)registering:(BackendlessUser *)user error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self registering:user];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)update:(BackendlessUser *)user error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self update:user];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self login:login password:password];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)findById:(NSString *)objectId error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self findById:objectId];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)logoutError:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self logout];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(NSNumber *)isValidUserTokenError:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self isValidUserToken];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)restorePassword:(NSString *)login error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self restorePassword:login];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(NSArray<UserProperty*> *)describeUserClassError:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self describeUserClass];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)user:(NSString *)user assignRole:(NSString *)role error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self user:user assignRole:role];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(BOOL)user:(NSString *)user unassignRole:(NSString *)role error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self user:user unassignRole:role];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}

-(NSArray<NSString*> *)getUserRolesError:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self getUserRoles];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loginWithFacebookSDK:session user:user fieldsMapping:fieldsMapping];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loginWithFacebookSDK:accessToken fieldsMapping:fieldsMapping];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loginWithFacebookSDK:accessToken permissions:permissions fieldsMapping:fieldsMapping];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BackendlessUser *)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self loginWithGoogleSignInSDK:idToken accessToken:accessToken permissions:permissions fieldsMapping:fieldsMapping];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return nil;
        }
        return result;
    }
}

-(BOOL)resendEmailConfirmation:(NSString *)email error:(Fault **)fault {
    
    id result = nil;
    @try {
        result = [self resendEmailConfirmation:email];
    }
    @catch (Fault *fault) {
        result = fault;
    }
    @finally {
        if ([result isKindOfClass:Fault.class]) {
            if (fault)(*fault) = result;
            return NO;
        }
        return YES;
    }
}


#endif

// sync methods with fault return (as exception)

-(BackendlessUser *)registering:(BackendlessUser *)user {
    
    if (!user) 
        return [backendless throwFault:FAULT_NO_USER];
    
    if (![user retrieveProperties])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user retrieveProperties]];
#if FILTRATION_USER_TOKEN_ON
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
#endif
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args];
#if 1
    return result;
#else
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    NSLog(@"$$$registering: result = %@", result);
    
    [user assignProperties:result];
    
    return user;
#endif
}

-(BackendlessUser *)update:(BackendlessUser *)user {
    
    if (!user) 
        return [backendless throwFault:FAULT_NO_USER];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user retrieveProperties]];
#if FILTRATION_USER_TOKEN_ON
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
#endif
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
#if PERSIST_CURRENTUSER_OFF
    [user assignProperties:result];
#else
    if ([result isKindOfClass:[BackendlessUser class]]) {
        user = result;
    }
    else {
        [user assignProperties:result];
    }

    if (_isStayLoggedIn && _currentUser && [user.objectId isEqualToString:_currentUser.objectId]) {
        [self updateCurrentUser:result];
    }
#endif
    
    return user;
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password {
    
    if (!login || !password || ![login length] || ![password length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:login, password, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(BackendlessUser *)findById:(NSString *)objectId {
    
    if (!objectId || ![objectId length])
        return [backendless throwFault:FAULT_NO_USER_ID];
    
    NSArray *args = @[objectId, @[]];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_FIND_BY_ID args:args];
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
    
    // http://bugs.backendless.com/browse/BKNDLSS-12841
    if (!_currentUser || !userToken)
#if 1
        return @(NO);
#else
        return [backendless throwFault:FAULT_USER_IS_NOT_LOGGED_IN];
#endif
    
    NSArray *args = @[userToken];
#if 0 // http://bugs.backendless.com/browse/BKNDLSS-11864
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args];
#else
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
#endif
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

-(id)user:(NSString *)user assignRole:(NSString *)role {
    
    if (!user||![user length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [backendless throwFault:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:user, role, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_ASSIGN_ROLE args:args];
    return result;
}

-(id)user:(NSString *)user unassignRole:(NSString *)role {
    
    if (!user||![user length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [backendless throwFault:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:user, role, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_UNASSIGN_ROLE args:args];
    return result;
}

-(NSArray<NSString*> *)getUserRoles {
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:@[]];
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    return [self loginWithFacebookSocialUserId:[user valueForKey:@"objectID"] accessToken:[[session valueForKey:@"accessTokenData"] valueForKey:@"accessToken"] expirationDate:[[session valueForKey:@"accessTokenData"] valueForKey:@"expirationDate"] permissions:[[session valueForKey:@"accessTokenData"] valueForKey:@"permissions"] fieldsMapping:fieldsMapping];
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    return [self loginWithFacebookSocialUserId:[accessToken valueForKey:@"userID"] accessToken:[accessToken valueForKey:@"tokenString"] expirationDate:[accessToken valueForKey:@"expirationDate"] permissions:[accessToken valueForKey:@"permissions"] fieldsMapping:fieldsMapping];
}

-(BackendlessUser *)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    return [self loginWithFacebookSocialUserId:[accessToken valueForKey:@"userID"] accessToken:[accessToken valueForKey:@"tokenString"] expirationDate:[accessToken valueForKey:@"expirationDate"] permissions:permissions fieldsMapping:fieldsMapping];
}

-(BackendlessUser *)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    
    if (!idToken||!idToken.length||!accessToken||!accessToken.length)
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = @[idToken, accessToken, permissions?permissions:@[], fieldsMapping?fieldsMapping:@{}];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(id)resendEmailConfirmation:(NSString *)email {
    
    if (!email||!email.length)
        return [backendless throwFault:FAULT_NO_USER_EMAIL];
    
    NSArray *args = @[email];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_RESEND_EMAIL_CONFIRMATION args:args];
}


// async methods with responder

-(void)registering:(BackendlessUser *)user responder:(id <IResponder>)responder {
    
    if (!user) 
        return [responder errorHandler:FAULT_NO_USER];
    
    if (![user retrieveProperties])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user retrieveProperties]];
#if FILTRATION_USER_TOKEN_ON
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
#endif
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(registerResponse:) selErrorHandler:@selector(registerError:)];
    _responder.chained = responder;
    _responder.context = user;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args responder:_responder];
}

-(void)update:(BackendlessUser *)user responder:(id <IResponder>)responder {
    
    if (!user) 
        return [responder errorHandler:FAULT_NO_USER];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user retrieveProperties]];
#if FILTRATION_USER_TOKEN_ON
    [props removeObjectsForKeys:@[BACKENDLESS_USER_TOKEN, BACKENDLESS_USER_REGISTERED]];
#endif
    NSArray *args = [NSArray arrayWithObjects:props, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUpdate:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = user;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args responder:_responder];
}

-(void)login:(NSString *)login password:(NSString *)password responder:(id <IResponder>)responder {
    
    if (!login || !password || ![login length] || ![password length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:login, password, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args responder:_responder];
}

-(void)findById:(NSString *)objectId responder:(id <IResponder>)responder {
    
    if (!objectId || ![objectId length])
        return [responder errorHandler:FAULT_NO_USER_ID];
    
    NSArray *args = @[objectId, @[]];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_FIND_BY_ID args:args responder:responder];
}

-(void)logout:(id <IResponder>)responder {
    
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogout:) selErrorHandler:@selector(onLogoutError:)];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:@[] responder:_responder];
}

-(void)isValidUserToken:(id <IResponder>)responder {
    
    NSString *userToken = [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
    
    // http://bugs.backendless.com/browse/BKNDLSS-12841
    if (!_currentUser || !userToken) {
#if 1
        [responder responseHandler:@(NO)];
        return;
#else
        return [responder errorHandler:FAULT_USER_IS_NOT_LOGGED_IN];
#endif
    }
    NSArray *args = @[userToken];
#if 1 // http://bugs.backendless.com/browse/BKNDLSS-11864
    Responder *_responder = [Responder responder:self selResponseHandler:nil selErrorHandler:@selector(onValidUserTokenFault:)];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args responder:_responder];
#else
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args responder:responder];
#endif
}

-(void)restorePassword:(NSString *)login responder:(id <IResponder>)responder {
    
    if (!login||!login.length)
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:login, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_RESTORE_PASSWORD args:args responder:responder];
}

-(void)describeUserClass:(id <IResponder>)responder {
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_DESCRIBE_USER_CLASS args:@[] responder:responder];
}

-(void)user:(NSString *)user assignRole:(NSString *)role responder:(id <IResponder>)responder {
    
    if (!user||![user length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [responder errorHandler:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:user, role, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_ASSIGN_ROLE args:args responder:responder];
}

-(void)user:(NSString *)user unassignRole:(NSString *)role responder:(id <IResponder>)responder {
    
    if (!user||![user length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [responder errorHandler:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:user, role, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_UNASSIGN_ROLE args:args responder:responder];
}

-(void)getUserRoles:(id<IResponder>)responder {
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:@[] responder:responder];
}

-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id<IResponder>)responder {
    [self loginWithFacebookSocialUserId:[user valueForKey:@"objectID"] accessToken:[[session valueForKey:@"accessTokenData"] valueForKey:@"accessToken"] expirationDate:[[session valueForKey:@"accessTokenData"] valueForKey:@"expirationDate"] permissions:[[session valueForKey:@"accessTokenData"] valueForKey:@"permissions"] fieldsMapping:fieldsMapping responder:responder];
}

-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder {
    [self loginWithFacebookSocialUserId:[accessToken valueForKey:@"userID"] accessToken:[accessToken valueForKey:@"tokenString"] expirationDate:[accessToken valueForKey:@"expirationDate"] permissions:[accessToken valueForKey:@"permissions"] fieldsMapping:fieldsMapping responder:responder];
}

-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder {
    [self loginWithFacebookSocialUserId:[accessToken valueForKey:@"userID"] accessToken:[accessToken valueForKey:@"tokenString"] expirationDate:[accessToken valueForKey:@"expirationDate"] permissions:permissions fieldsMapping:fieldsMapping responder:responder];
}

-(void)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id<IResponder>)responder {
    
    if (!idToken||!idToken.length||!accessToken||!accessToken.length)
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = @[idToken, accessToken, permissions?permissions:@[], fieldsMapping?fieldsMapping:@{}];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_GOOGLEPLUS_SDK args:args responder:_responder];
}

-(void)resendEmailConfirmation:(NSString *)email responder:(id <IResponder>)responder {
    
    if (!email||!email.length)
        return [responder errorHandler:FAULT_NO_USER_EMAIL];
    
    NSArray *args = @[email];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_RESEND_EMAIL_CONFIRMATION args:args responder:responder];
    
}

// async methods with block-based callbacks

-(void)registering:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self registering:user responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)update:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self update:user responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)login:(NSString *)login password:(NSString *)password response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self login:login password:password responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)findById:(NSString *)objectId response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self findById:objectId responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)logout:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self logout:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)isValidUserToken:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self isValidUserToken:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)restorePassword:(NSString *)login response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self restorePassword:login responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)describeUserClass:(void(^)(NSArray<UserProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self describeUserClass:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)user:(NSString *)user assignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self user:user assignRole:role responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)user:(NSString *)user unassignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self user:user unassignRole:role responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getUserRoles:(void (^)(NSArray<NSString*> *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self getUserRoles:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<FBGraphUser> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loginWithFacebookSDK:session user:user fieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loginWithFacebookSDK:accessToken fieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loginWithFacebookSDK:accessToken permissions:permissions fieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loginWithGoogleSignInSDK:idToken accessToken:accessToken permissions:permissions fieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)resendEmailConfirmation:(NSString *)email response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self resendEmailConfirmation:email responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// methods of social easy logins

// Facebook
-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions
{
    [self easyLoginWithFacebookFieldsMapping:fieldsMapping permissions:permissions responder:nil];
}

-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions responder:(id<IResponder>)responder
{
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}, permissions?permissions:@{}];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK args:args responder:_responder];
}

-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self easyLoginWithFacebookFieldsMapping:fieldsMapping permissions:permissions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

#if 1
-(void)easyLoginWithFacebookUrlFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions responder:(id<IResponder>)responder {
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}, permissions?permissions:@{}];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK args:args responder:responder];
}

-(void)easyLoginWithFacebookUrlFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions response:(void(^)(NSString *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self easyLoginWithFacebookUrlFieldsMapping:fieldsMapping permissions:permissions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
#endif

// TWitter
-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping
{
    [self easyLoginWithTwitterFieldsMapping:fieldsMapping responder:nil];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder
{
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER args:args responder:_responder];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self easyLoginWithTwitterFieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// Google+
-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions
{
    [self easyLoginWithGooglePlusFieldsMapping:fieldsMapping permissions:permissions responder:nil];
}

-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions responder:(id<IResponder>)responder
{
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = @[backendless.applicationType, fieldsMapping?fieldsMapping:@{}, permissions?permissions:@{}];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_GOOGLEPLUS args:args responder:_responder];
}

-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self easyLoginWithGooglePlusFieldsMapping:fieldsMapping permissions:permissions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// utilites

-(id)handleOpenURL:(NSURL *)url {
    
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
    
#if 1 // http://bugs.backendless.com/browse/BKNDLSS-13234
    NSString *substr;
    NSUInteger index = json?json.length:0;
    while (index) {
        substr = [json substringFromIndex:--index];
        if ([substr isEqualToString:@"}"])
            break;
        json = [json substringToIndex:index];
    };
#endif
    
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
#if REPEAT_EASYLOGIN_ON && !_USE_SAFARI_VC_
            if (_easyLoginUrl) {
                [self easyLoginResponder:_easyLoginUrl];
                _easyLoginUrl = nil;
            }
#endif
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
#if REPEAT_EASYLOGIN_ON
             if (!user && _easyLoginUrl) {
                 [self easyLoginResponder:_easyLoginUrl];
                 _easyLoginUrl = nil;
             }
             else {
                 if (completion) {
                     completion(user);
                 }
             }
#else
             if (completion) {
                 completion(user);
             }
#endif
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
    _currentUser = obj ? [[BackendlessUser alloc] initWithProperties:obj] : nil;
    _isStayLoggedIn = (BOOL)_currentUser;
    if (_isStayLoggedIn && _currentUser.getUserToken) {
        [backendless.headers setValue:_currentUser.getUserToken forKey:BACKENDLESS_USER_TOKEN];
    }
    else {
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    }
    
    //[DebLog logY:@"UserService -> getPersistentUser: currentUser = %@ [%@]", [_currentUser getObjectId], _isStayLoggedIn?@"ON":@"OFF"];
    
    return _isStayLoggedIn;
}

-(BOOL)setPersistentUser {
#if 0
    return (_currentUser && _isStayLoggedIn) ? [AMFSerializer serializeToFile:[_currentUser retrieveProperties] fileName:PERSIST_USER_FILE_NAME] : NO;
#else
    if (_currentUser && _isStayLoggedIn) {
        
        NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:[_currentUser retrieveProperties]];
        NSString *userToken = [backendless.headers valueForKey:BACKENDLESS_USER_TOKEN];
        if (userToken) {
            [properties setValue:userToken forKey:BACKENDLESS_USER_TOKEN];
        }
        return [AMFSerializer serializeToFile:properties fileName:PERSIST_USER_FILE_NAME];
    }
    return NO;

#endif
}

-(BOOL)resetPersistentUser {
    return [AMFSerializer serializeToFile:nil fileName:PERSIST_USER_FILE_NAME];
}

#pragma mark -
#pragma mark Private Methods

// sync
-(BackendlessUser *)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate  permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping {
    
    NSArray *args = @[userId, accessToken, expirationDate, permissions, fieldsMapping?fieldsMapping:@{}];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

//async
-(void)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id<IResponder>)responder {
    
    NSArray *args = @[userId, accessToken, expirationDate, permissions, fieldsMapping?fieldsMapping:@{}];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args responder:_responder];
}

// callbacks

-(id)registerError:(id)error {
    
    [DebLog log:@"UserService -> registerError: %@", error];
    return error;
}

-(id)registerResponse:(ResponseContext *)response {
    
    [DebLog log:@"UserService -> registerResponse: %@", response];
    
    BackendlessUser *user = response.context;
    [user assignProperties:response.response];
    return user;
}

-(id)easyLoginError:(Fault *)fault {
    
#if REPEAT_EASYLOGIN_ON
    _easyLoginUrl = nil;
#endif

    [DebLog log:@"UserService -> easyLoginError: %@", fault.detail];
    return fault;
}

-(id)easyLoginResponder:(id)response {
    
#if REPEAT_EASYLOGIN_ON
    self.easyLoginUrl = (NSString *)response;
#endif
    
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
#else
    [[NSWorkspace sharedWorkspace] openURL:url];
#endif
    return @(YES);
}

-(id)onLogin:(id)response {
    
    if ([response isKindOfClass:[BackendlessUser class]]) {
        self.currentUser = response;
    }
    else {
        NSDictionary *props = (NSDictionary *)response;
        (_currentUser) ? [_currentUser assignProperties:props] : (_currentUser = [[BackendlessUser alloc] initWithProperties:props]);
    }
    
    if (_currentUser.getUserToken)
        [backendless.headers setValue:_currentUser.getUserToken forKey:BACKENDLESS_USER_TOKEN];
    else
        [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    
    [DebLog log:@"UserService -> onLogin: response = %@\n backendless.headers = %@", response, backendless.headers];
    
    [self setPersistentUser];
    
    return _currentUser;
}

-(void)updateCurrentUser:(id)response {
    
    if ([response isKindOfClass:[BackendlessUser class]]) {
        self.currentUser = response;
    }
    else {
        NSDictionary *props = (NSDictionary *)response;
        (_currentUser) ? [_currentUser assignProperties:props] : (_currentUser = [[BackendlessUser alloc] initWithProperties:props]);
    }
    
    [self setPersistentUser];
}

-(id)onUpdate:(ResponseContext *)response {
    
    [DebLog log:@"UserService -> onUpdate: %@", response];
    
    BackendlessUser *user = response.context;
#if PERSIST_CURRENTUSER_OFF
    [user assignProperties:response.response];
#else
    id result = response.response;
    if ([result isKindOfClass:[BackendlessUser class]]) {
        user = result;
    }
    else {
        [user assignProperties:result];
    }
    
    if (_isStayLoggedIn && _currentUser && [user.objectId isEqualToString:_currentUser.objectId]) {
        [self updateCurrentUser:result];
    }
#endif
    
    return user;
}

-(id)onLogout:(id)response {
    
    [DebLog log:@"UserService -> onLogout: %@", response];
    
    if (_currentUser) [_currentUser release];
    _currentUser = nil;
    
    [backendless.headers removeObjectForKey:BACKENDLESS_USER_TOKEN];
    
    [self resetPersistentUser];
    
    return response;
}

// fix BKNDLSS-6164 & BKNDLSS-6173
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

// fix BKNDLSS-11864
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
    /* if ur using any Customs classes, do like this.
     * Here SlideNavigationController is a subclass of UINavigationController.
     * And ensure you check the custom classes before native controllers , if u have any in your hierarchy.
     if ([inController isKindOfClass:[SlideNavigationController class]])
     {
     return [self findTopViewController:[inController visibleViewController]];
     }
     else */
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

