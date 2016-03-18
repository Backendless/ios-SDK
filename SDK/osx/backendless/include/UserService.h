//
//  UserService.h
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

#import <Foundation/Foundation.h>

@class BackendlessUser, Fault, UserProperty;
@protocol IResponder;
// FB
@class FBSDKAccessToken;
@class FBSession;
@protocol FBGraphUser;

@interface UserService : NSObject

@property (strong, nonatomic, readonly) BackendlessUser *currentUser;
@property (readonly) BOOL isStayLoggedIn;

// switch on/off the persistent user mode
-(BOOL)setStayLoggedIn:(BOOL)value;

// sync methods with fault return  (as exception)
-(BackendlessUser *)registering:(BackendlessUser *)user;
-(BackendlessUser *)update:(BackendlessUser *)user;
-(BackendlessUser *)login:(NSString *)login password:(NSString *)password;
-(BackendlessUser *)findById:(NSString *)objectId;
-(id)logout;
-(NSNumber *)isValidUserToken;
-(id)restorePassword:(NSString *)login;
-(NSArray<UserProperty*> *)describeUserClass;
-(id)user:(NSString *)user assignRole:(NSString *)role;
-(id)user:(NSString *)user unassignRole:(NSString *)role;
-(NSArray<NSString*> *)getUserRoles;
-(id)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping;
-(id)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping;
-(id)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping;

// sync methods with fault option
-(BackendlessUser *)registering:(BackendlessUser *)user error:(Fault **)fault;
-(BackendlessUser *)update:(BackendlessUser *)user error:(Fault **)fault;
-(BackendlessUser *)login:(NSString *)login password:(NSString *)password error:(Fault **)fault;
-(BackendlessUser *)findById:(NSString *)objectId error:(Fault **)fault;
-(BOOL)logoutError:(Fault **)fault;
-(NSNumber *)isValidUserTokenError:(Fault **)fault;
-(BOOL)restorePassword:(NSString *)login error:(Fault **)fault;
-(NSArray<UserProperty*> *)describeUserClassError:(Fault **)fault;
-(BOOL)user:(NSString *)user assignRole:(NSString *)role error:(Fault **)fault;
-(BOOL)user:(NSString *)user unassignRole:(NSString *)role error:(Fault **)fault;
-(NSArray<NSString*> *)getUserRolesError:(Fault **)fault;
-(BackendlessUser *)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault;
-(BackendlessUser *)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault;
-(BackendlessUser *)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping error:(Fault **)fault;

// async methods with responder
-(void)registering:(BackendlessUser *)user responder:(id <IResponder>)responder;
-(void)update:(BackendlessUser *)user responder:(id <IResponder>)responder;
-(void)login:(NSString *)login password:(NSString *)password responder:(id <IResponder>)responder;
-(void)findById:(NSString *)objectId responder:(id <IResponder>)responder;
-(void)logout:(id <IResponder>)responder;
-(void)isValidUserToken:(id <IResponder>)responder;
-(void)restorePassword:(NSString *)login responder:(id <IResponder>)responder;
-(void)describeUserClass:(id <IResponder>)responder;
-(void)user:(NSString *)user assignRole:(NSString *)role responder:(id <IResponder>)responder;
-(void)user:(NSString *)user unassignRole:(NSString *)role responder:(id <IResponder>)responder;
-(void)getUserRoles:(id <IResponder>)responder;
-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder;
-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id <IResponder>)responder;
-(void)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id<IResponder>)responder;

// async methods with block-based callbacks
-(void)registering:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)login:(NSString *)login password:(NSString *)password response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)logout:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)isValidUserToken:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)restorePassword:(NSString *)login response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describeUserClass:(void(^)(NSArray<UserProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)user:(NSString *)user assignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)user:(NSString *)user unassignRole:(NSString *)role response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getUserRoles:(void(^)(NSArray<NSString*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithFacebookSDK:(FBSession *)session user:(NSDictionary<FBGraphUser> *)user fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithFacebookSDK:(FBSDKAccessToken *)accessToken fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithGoogleSignInSDK:(NSString *)idToken accessToken:(NSString *)accessToken permissions:(NSArray<NSString*> *)permissions fieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;

// methods of social easy logins
// Facebook
-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions;
-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions responder:(id<IResponder>)responder;
-(void)easyLoginWithFacebookFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
// Twitter
-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping;
-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping responder:(id<IResponder>)responder;
-(void)easyLoginWithTwitterFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping response:(void(^)(NSNumber *))responseBlock error:(void(^)(Fault *))errorBlock;
// Google+
-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions;
-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions responder:(id<IResponder>)responder;
-(void)easyLoginWithGooglePlusFieldsMapping:(NSDictionary<NSString*,NSString*> *)fieldsMapping permissions:(NSArray<NSString*> *)permissions response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock;

// utilites
-(id)handleOpenURL:(NSURL *)url;

// persistent user
-(BOOL)getPersistentUser;
-(BOOL)setPersistentUser;
-(BOOL)resetPersistentUser;

@end
