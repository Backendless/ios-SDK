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

#define FAULT_NO_USER [Fault fault:@"user is not exist" detail:@"backendless user is not exist" faultCode:@"3100"]
#define FAULT_NO_USER_ID [Fault fault:@"user ID is not exist" detail:@"backendless user ID is not exist" faultCode:@"3101"]
#define FAULT_NO_USER_CREDENTIALS [Fault fault:@"user credentials is not valid" detail:@"backendless user credentials is not valid" faultCode:@"3102"]
#define FAULT_NO_USER_ROLE [Fault fault:@"user role is not valid" detail:@"user role is not valid" faultCode:@"3103"]
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
static NSString *METHOD_ASSIGN_ROLE = @"assignRole";
static NSString *METHOD_UNASSIGN_ROLE = @"unassignRole";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK = @"getFacebookServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_TWITTER = @"getTwitterServiceAuthorizationUrlLink";
static NSString *METHOD_USER_LOGIN_WITH_FACEBOOK_SDK = @"loginWithFacebook";
static NSString *METHOD_GET_USER_ROLES = @"getUserRoles";
static NSString *METHOD_IS_VALID_USER_TOKEN = @"isValidUserToken"; 
//  BACKENDLESS HEADER KEYS
static NSString *USER_TOKEN_KEY = @"user-token\0";

@interface UserService ()
// sync
-(id)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping;
// async
-(void)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping responder:(id <IResponder>)responder;
// callbacks
-(id)registerResponse:(ResponseContext *)response;
-(id)registerError:(id)error;
-(id)easyLoginResponder:(id)response;
-(id)easyLoginError:(Fault *)fault;
-(id)onLogin:(id)response;
-(id)onUpdate:(ResponseContext *)response;
-(id)onLogout:(id)response;
-(id)onLogoutError:(Fault *)fault;
// persistent user
-(BOOL)getPersistentUser;
-(BOOL)setPersistentUser;
-(BOOL)resetPersistentUser;
@end

@implementation UserService

-(id)init {
	if ( (self=[super init]) ) {
        
        _currentUser = nil;
        _isStayLoggedIn = NO;
        
        [self getPersistentUser];

        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.UserProperty" mapped:[UserProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.AbstractProperty" mapped:[AbstractProperty class]];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UserService"];
    
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

// sync methods with fault return  (as exception)

-(BackendlessUser *)registering:(BackendlessUser *)user {
    
    if (!user) 
        return [backendless throwFault:FAULT_NO_USER];
    
    if (![user getProperties])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [user getProperties], nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    [user setProperties:result];
    
    return user;
}

-(BackendlessUser *)update:(BackendlessUser *)user {
    
    if (!user) 
        return [backendless throwFault:FAULT_NO_USER];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectForKey:BACKENDLESS_USER_TOKEN];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, props, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }

    [self onLogin:result];
    [user setProperties:result];
    
    return user;
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password {
    
    if (!login || !password || ![login length] || ![password length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, login, password, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(id)logout {
    
    BOOL throwException = invoker.throwException;
    invoker.throwException = NO;
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:args];
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

    if (!_currentUser || !_currentUser.userToken)
        return [backendless throwFault:FAULT_NO_USER];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _currentUser.userToken];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args];
}


-(id)restorePassword:(NSString *)login {
    
    if (!login)
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, login, nil];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_RESTORE_PASSWORD args:args];
}

-(NSArray *)describeUserClass {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_DESCRIBE_USER_CLASS args:args];
}

-(id)user:(NSString *)user assignRole:(NSString *)role {
    
    if (!user||![user length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [backendless throwFault:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, user, role, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_ASSIGN_ROLE args:args];
    return result;
}

-(id)user:(NSString *)user unassignRole:(NSString *)role {
    
    if (!user||![user length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [backendless throwFault:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, user, role, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_UNASSIGN_ROLE args:args];
    return result;
}

-(id)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping {
    
    return [self loginWithFacebookSocialUserId:[user valueForKey:@"id"] accessToken:[[session valueForKey:@"accessTokenData"] valueForKey:@"accessToken"] expirationDate:[[session valueForKey:@"accessTokenData"] valueForKey:@"expirationDate"] permissions:[[session valueForKey:@"accessTokenData"] valueForKey:@"permissions"] fieldsMapping:fieldsMapping];
}

-(id)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, userId, accessToken, expirationDate, permissions, fieldsMapping, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args];
    return [result isKindOfClass:[Fault class]] ? result : [self onLogin:result];
}

-(NSArray *)getUserRoles {
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    return [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:args];
}

// async methods with responder

-(void)registering:(BackendlessUser *)user responder:(id <IResponder>)responder {
    
    if (!user) 
        return [responder errorHandler:FAULT_NO_USER];
    if (![user getProperties])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, [user getProperties], nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(registerResponse:) selErrorHandler:@selector(registerError:)];
    _responder.chained = responder;
    _responder.context = user;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_REGISTER args:args responder:_responder];
}

-(void)update:(BackendlessUser *)user responder:(id <IResponder>)responder {
    
    if (!user) 
        return [responder errorHandler:FAULT_NO_USER];
    
    NSMutableDictionary *props = [NSMutableDictionary dictionaryWithDictionary:[user getProperties]];
    [props removeObjectForKey:BACKENDLESS_USER_TOKEN];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, props, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onUpdate:) selErrorHandler:nil];
    _responder.chained = responder;
    _responder.context = user;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_UPDATE args:args responder:_responder];
}

-(void)login:(NSString *)login password:(NSString *)password responder:(id <IResponder>)responder {
    
    if (!login || !password || ![login length] || ![password length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, login, password, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args responder:_responder];
}

-(void)logout:(id <IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogout:) selErrorHandler:@selector(onLogoutError:)];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:args responder:_responder];
}

-(void)isValidUserToken:(id <IResponder>)responder {
    
    if (!_currentUser || !_currentUser.userToken)
        return [responder errorHandler:FAULT_NO_USER];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, _currentUser.userToken];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_IS_VALID_USER_TOKEN args:args responder:responder];
}

-(void)restorePassword:(NSString *)login responder:(id <IResponder>)responder {
    
    if (!login)
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, login, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_RESTORE_PASSWORD args:args responder:responder];
}

-(void)describeUserClass:(id <IResponder>)responder {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_DESCRIBE_USER_CLASS args:args responder:responder];
}

-(void)user:(NSString *)user assignRole:(NSString *)role responder:(id <IResponder>)responder
{
    if (!user||![user length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [responder errorHandler:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, user, role, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_ASSIGN_ROLE args:args responder:responder];
}

-(void)user:(NSString *)user unassignRole:(NSString *)role responder:(id <IResponder>)responder
{
    if (!user||![user length])
        return [responder errorHandler:FAULT_NO_USER_CREDENTIALS];
    if (!role||![role length]) {
        return [responder errorHandler:FAULT_NO_USER_ROLE];
    }
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, user, role, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_UNASSIGN_ROLE args:args responder:responder];
}

-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping responder:(id<IResponder>)responder
{
    [self loginWithFacebookSocialUserId:[user valueForKey:@"id"] accessToken:[[session valueForKey:@"accessTokenData"] valueForKey:@"accessToken"] expirationDate:[[session valueForKey:@"accessTokenData"] valueForKey:@"expirationDate"] permissions:[[session valueForKey:@"accessTokenData"] valueForKey:@"permissions"] fieldsMapping:fieldsMapping responder:responder];
}

-(void)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping responder:(id<IResponder>)responder
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, userId, accessToken, expirationDate, permissions, fieldsMapping, nil];
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogin:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args responder:_responder];
}

-(void)getUserRoles:(id<IResponder>)responder
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_GET_USER_ROLES args:args responder:responder];

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

-(void)logout:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self logout:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)isValidUserToken:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self isValidUserToken:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)restorePassword:(NSString *)login response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self restorePassword:login responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)describeUserClass:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock {
    [self describeUserClass:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)user:(NSString *)user assignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self user:user assignRole:role responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)user:(NSString *)user unassignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self user:user unassignRole:role responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<FBGraphUser> *)fieldsMapping response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    [self loginWithFacebookSDK:session user:user fieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}
-(void)getUserRoles:(void (^)(NSArray *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self getUserRoles:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// async social easy logins

-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary *)fieldsMapping permissions:(NSArray *)permissions responder:(id<IResponder>)responder
{
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, backendless.applicationType, fieldsMapping, permissions, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK args:args responder:_responder];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary *)fieldsMapping responder:(id <IResponder>)responder
{
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(easyLoginResponder:) selErrorHandler:@selector(easyLoginError:)];
    _responder.chained = responder;
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, backendless.applicationType, fieldsMapping, nil];
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_TWITTER args:args responder:_responder];
}

-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary *)fieldsMapping permissions:(NSArray *)permissions
{
    [self easyLoginWithFacebookFieldsMapping:fieldsMapping permissions:permissions responder:nil];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary *)fieldsMapping
{
    [self easyLoginWithTwitterFieldsMapping:fieldsMapping responder:nil];
}

-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary *)fieldsMapping response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self easyLoginWithTwitterFieldsMapping:fieldsMapping responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary *)fieldsMapping permissions:(NSArray *)permissions response:(void (^)(id))responseBlock error:(void (^)(Fault *))errorBlock
{
    [self easyLoginWithFacebookFieldsMapping:fieldsMapping permissions:permissions responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// utilites

-(id)handleOpenURL:(NSURL *)url {
    
    [DebLog log:@"UserService -> handleOpenURL: url.scheme = '%@'", url.scheme];
    
    NSString *scheme = [[NSString stringWithFormat:@"backendless%@", backendless.appID] uppercaseString];
    if (![[url.scheme uppercaseString] isEqualToString:scheme]) {
        return nil;
    }
    
    NSString *absoluteString = [[url.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://", url.scheme] withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    id userData = [NSJSONSerialization JSONObjectWithData:[absoluteString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return [self onLogin:userData];
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
    
    [DebLog log:@"UserService -> easyLoginResponder: %@ [%@]", response, url.scheme];
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [[UIApplication sharedApplication] openURL:url];
#else
    [[NSWorkspace sharedWorkspace] openURL:url];
#endif
    return @(YES);
}

-(id)onLogin:(id)response {
    
    if ([response isKindOfClass:[BackendlessUser class]]) {
        [_currentUser release];
        _currentUser = response;
    }
    else {
        NSDictionary *props = (NSDictionary *)response;
        (_currentUser) ? [_currentUser setProperties:props] : (_currentUser = [[BackendlessUser alloc] initWithProperties:props]);        
    }
    
    if (_currentUser.userToken)
        [backendless.headers setValue:_currentUser.userToken forKey:USER_TOKEN_KEY];
    
    [DebLog log:@"UserService -> onLogin: response = %@\n backendless.headers = %@", response, backendless.headers];
    
    [self setPersistentUser];
    
    return _currentUser;
}

-(id)onUpdate:(ResponseContext *)response {
    
    [DebLog log:@"UserService -> onUpdate: %@", response];
    
    [self onLogin:response.response];
    
    BackendlessUser *user = response.context;
    [user setProperties:response.response];
    
    return user;
}

-(id)onLogout:(id)response {
    
    [DebLog log:@"UserService -> onLogout: %@", response];
    
    if (_currentUser) [_currentUser release];
    _currentUser = nil;
    
    [backendless.headers removeObjectForKey:USER_TOKEN_KEY];
    
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


// persistent user

-(BOOL)getPersistentUser {
    
    id obj = [AMFSerializer deserializeFromFile:PERSIST_USER_FILE_NAME];
    _currentUser = obj ? [[BackendlessUser alloc] initWithProperties:obj] : nil;
    _isStayLoggedIn = (BOOL)_currentUser;
    if (_isStayLoggedIn && _currentUser.userToken) {
        [backendless.headers setValue:_currentUser.userToken forKey:USER_TOKEN_KEY];
    }
    
    [DebLog log:@"UserService -> getPersistentUser: currentUser = %@", _currentUser];

    return _isStayLoggedIn;
}

-(BOOL)setPersistentUser {
    return (_currentUser && _isStayLoggedIn) ? [AMFSerializer serializeToFile:[_currentUser getProperties] fileName:PERSIST_USER_FILE_NAME] : NO;
    
}

-(BOOL)resetPersistentUser {
    return [AMFSerializer serializeToFile:nil fileName:PERSIST_USER_FILE_NAME];
}

@end
