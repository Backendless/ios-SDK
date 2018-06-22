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
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
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
@class FBSDKAccessToken;

@interface UserService : NSObject

@property (strong, nonatomic) BackendlessUser *currentUser;
@property (readonly) BOOL isStayLoggedIn;

-(BOOL)setStayLoggedIn:(BOOL)value;

// sync methods with fault return (as exception)
-(BackendlessUser *)registerUser:(BackendlessUser *)user;
-(BackendlessUser *)update:(BackendlessUser *)user;
-(BackendlessUser *)login:(NSString *)login password:(NSString *)password;
-(BackendlessUser *)findById:(NSString *)objectId;
-(void)logout;
-(BOOL)isValidUserToken;
-(void)restorePassword:(NSString *)email;
-(NSArray<UserProperty*> *)describeUserClass;
-(NSArray<NSString*> *)getUserRoles;
-(BackendlessUser *)loginWithFacebookSDK:(NSString *)userId tokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate fieldsMapping:(NSDictionary *)fieldsMapping;
-(BackendlessUser *)loginWithGoogleSDK:(NSString *)idToken accessToken:(NSString *)accessToken;
-(BackendlessUser *)loginWithTwitterSDK:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret fieldsMapping:(NSDictionary *)fieldsMapping;
-(void)resendEmailConfirmation:(NSString *)email;

// async methods with block-based callbacks
-(void)registerUser:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)update:(BackendlessUser *)user response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)login:(NSString *)login password:(NSString *)password response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)findById:(NSString *)objectId response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)logout:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)isValidUserToken:(void(^)(BOOL))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)restorePassword:(NSString *)email response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)describeUserClass:(void(^)(NSArray<UserProperty*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getUserRoles:(void(^)(NSArray<NSString*> *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithFacebookSDK:(NSString *)userId tokenString:(NSString *)tokenString expirationDate:(NSDate *)expirationDate fieldsMapping:(NSDictionary *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithGoogleSDK:(NSString *)idToken accessToken:(NSString *)accessToken response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)loginWithTwitterSDK:(NSString *)authToken authTokenSecret:(NSString *)authTokenSecret fieldsMapping:(NSDictionary *)fieldsMapping response:(void(^)(BackendlessUser *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)resendEmailConfirmation:(NSString *)email response:(void(^)(void))responseBlock error:(void(^)(Fault *))errorBlock;

// persistent user
-(BOOL)getPersistentUser;
-(BOOL)setPersistentUser;
-(BOOL)resetPersistentUser;

@end
