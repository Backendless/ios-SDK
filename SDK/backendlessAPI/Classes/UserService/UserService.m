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

#define FAULT_NO_USER [Fault fault:@"user is not exist" detail:@"backendless user is not exist" faultCode:@"3100"]
#define FAULT_NO_USER_ID [Fault fault:@"user ID is not exist" detail:@"backendless user ID is not exist" faultCode:@"3101"]
#define FAULT_NO_USER_CREDENTIALS [Fault fault:@"user credentials is not valid" detail:@"backendless user credentials is not valid" faultCode:@"3102"]
#define FAULT_NO_USER_ROLE [Fault fault:@"user role is not valid" detail:@"user role is not valid" faultCode:@"3103"]
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
#pragma mark -
#pragma mark UserServiceResponder Class

@interface Users : NSObject
@end
@implementation Users
@end

@interface UserServiceResponder : Responder {
    BackendlessUser *_user;
}
@property (nonatomic, assign) BackendlessUser *current;

+(id)responder:(BackendlessUser *)user chained:(Responder *)responder;
-(id)onResponse:(id)response;

@end

@implementation UserServiceResponder

-(id)initWithUser:(BackendlessUser *)user chained:(Responder *)responder {
    
    if ( (self = [super init]) ) {
        _responder = self;
        _responseHandler = @selector(onResponse:);
        _errorHandler = nil;
        self.chained = responder;
        _user = user;
        _current = nil;
    }
    
    return self;
    
}

+(id)responder:(BackendlessUser *)_user chained:(Responder *)responder {
    return [[[UserServiceResponder alloc] initWithUser:_user chained:responder] autorelease];
}

// async callback

-(id)onResponse:(id)response {
    
    if (_user)
        [_user setProperties:response];
        
    if (_current)
        [_current setProperties:response];
    
    return _user;
}

@end


#pragma mark -
#pragma mark UserService Class

@interface UserService ()

//-(BackendlessUser *)registering:(BackendlessUser *)user;
//-(BackendlessUser *)update:(BackendlessUser *)user;
//-(BackendlessUser *)login:(NSString *)login password:(NSString *)password;
//-(id)logout;
//-(id)restorePassword:(NSString *)login;
//-(NSArray *)describeUserClass;
//-(id)user:(NSString *)user assignRole:(NSString *)role;
//-(id)user:(NSString *)user unassignRole:(NSString *)role;
//-(id)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping;
//-(NSArray *)getUserRoles;

// sync
-(id)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping;
// async
-(void)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping responder:(id <IResponder>)responder;
// callbacks
-(id)onLogin:(id)response;
-(id)onLogout:(id)response;
-(id)easyLoginResponder:(id)response;
-(id)easyLoginError:(Fault *)fault;
-(id)registerResponse:(id)response;
-(id)registerError:(id)error;
@end

@implementation UserService

-(id)init {
	if ( (self=[super init]) ) {
        _currentUser = nil;
        /*/
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.UserProperty" mapped:[UserProperty class]];
        /*/
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.UserProperty" mapped:[UserProperty class]];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.users.property.AbstractProperty" mapped:[AbstractProperty class]];
        //
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

// sync methods

-(BackendlessUser *)registering:(BackendlessUser *)user error:(Fault **)fault
{
    id result = [self registering:user];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BackendlessUser *)update:(BackendlessUser *)user error:(Fault **)fault
{
    id result = [self update:user];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BackendlessUser *)login:(NSString *)login password:(NSString *)password error:(Fault **)fault
{
    id result = [self login:login password:password];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)logoutError:(Fault **)fault
{
    id result = [self logout];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BOOL)restorePassword:(NSString *)login error:(Fault **)fault
{
    id result = [self restorePassword:login];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(NSArray *)describeUserClassError:(Fault **)fault
{
    id result = [self describeUserClass];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(BOOL)user:(NSString *)user assignRole:(NSString *)role error:(Fault **)fault
{
    id result = [self user:user assignRole:role];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BOOL)user:(NSString *)user unassignRole:(NSString *)role error:(Fault **)fault
{
    id result = [self user:user unassignRole:role];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return NO;
    }
    return YES;
}
-(BackendlessUser *)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping error:(Fault **)fault
{
    id result = [self loginWithFacebookSDK:session user:user fieldsMapping:fieldsMapping];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}
-(NSArray *)getUserRolesError:(Fault **)fault
{
    id result = [self getUserRoles];
    if ([result isKindOfClass:[Fault class]]) {
        (*fault) = result;
        return nil;
    }
    return result;
}


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
    NSLog(@"%@", [Types propertyDictionary:result]);
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    [user setProperties:result];
    [_currentUser setProperties:result];
   
    return user;
}

-(BackendlessUser *)login:(NSString *)login password:(NSString *)password {
    
    if (!login || !password || ![login length] || ![password length])
        return [backendless throwFault:FAULT_NO_USER_CREDENTIALS];
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, login, password, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGIN args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    
    return [self onLogin:result];
}

-(id)logout {
    
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        Fault *f = result;
        if ([f.faultCode isEqualToString:@"3064"] || [f.faultCode isEqualToString:@"3090"] || [f.faultCode isEqualToString:@"3091"]) {
            return [self onLogout:f];
        }
        return result;
    }
    
    return [self onLogout:result];
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

-(id)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary *)fieldsMapping
{
    return [self loginWithFacebookSocialUserId:[user valueForKey:@"id"] accessToken:[[session valueForKey:@"accessTokenData"] valueForKey:@"accessToken"] expirationDate:[[session valueForKey:@"accessTokenData"] valueForKey:@"expirationDate"] permissions:[[session valueForKey:@"accessTokenData"] valueForKey:@"permissions"] fieldsMapping:fieldsMapping];
}

-(id)loginWithFacebookSocialUserId:(NSString *)userId accessToken:(NSString *)accessToken expirationDate:(NSDate *)expirationDate permissions:(NSArray *)permissions fieldsMapping:(NSDictionary *)fieldsMapping
{
    NSArray *args = [NSArray arrayWithObjects:backendless.appID, backendless.versionNum, userId, accessToken, expirationDate, permissions, fieldsMapping, nil];
    id result = [invoker invokeSync:SERVER_USER_SERVICE_PATH method:METHOD_USER_LOGIN_WITH_FACEBOOK_SDK args:args];
    if ([result isKindOfClass:[Fault class]]) {
        return result;
    }
    NSLog(@"%@", result);
    return [self onLogin:result];
}
-(NSArray *)getUserRoles
{
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
    UserServiceResponder *_responder = [UserServiceResponder responder:user chained:responder];
    _responder.current = backendless.userService.currentUser;
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
    Responder *_responder = [Responder responder:self selResponseHandler:@selector(onLogout:) selErrorHandler:nil];
    _responder.chained = responder;
    [invoker invokeAsync:SERVER_USER_SERVICE_PATH method:METHOD_LOGOUT args:args responder:_responder];
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
// async methods with block-base callbacks

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
    return error;
}

-(id)registerResponse:(ResponseContext *)response {
    
    [DebLog log:@"UserService -> registerResponse: response = '%@'", response];
    
    BackendlessUser *user = response.context;
    [user setProperties:response.response];
    return user;
}
-(id)easyLoginError:(Fault *)fault
{
    [DebLog log:@"UserService -> easyLoginError: Error = '%@'", fault.detail];
    return fault;
}
-(id)easyLoginResponder:(id)response {
    
    [DebLog log:@"UserService -> easyLoginResponder: response = '%@'", response];
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:response]];
#else
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:response]];
#endif
    return [NSNumber numberWithBool:YES];
}

-(id)onLogin:(id)response {
    
    NSDictionary *props = (NSDictionary *)response;
    (_currentUser) ? [_currentUser setProperties:props] : (_currentUser = [[BackendlessUser alloc] initWithProperties:props]);
    if (_currentUser.userToken)
        [backendless.headers setValue:_currentUser.userToken forKey:@"user-token\0"];
    return _currentUser;
}

-(id)onLogout:(id)response {
    
    if (_currentUser) [_currentUser release];
    _currentUser = nil;
    
    [backendless.headers removeObjectForKey:@"user-token\0"];
    
    return response;
}

@end
