//
//  BackendlessUser.h
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

#define FILTRATION_USER_TOKEN_ON 1

#define BACKENDLESS_EMAIL_KEY @"email"
#define BACKENDLESS_NAME_KEY @"name"
#define BACKENDLESS_PASSWORD_KEY @"password"
#define BACKENDLESS_ID_KEY @"id"
#define BACKENDLESS_USER_TOKEN @"user-token"
#define BACKENDLESS_USER_REGISTERED @"user-registered"

@interface BackendlessUser : NSObject

@property (nonatomic, assign, getter = getObjectId, setter = setObjectId:) NSString *objectId;
@property (nonatomic, assign, getter = getEmail, setter = setEmail:) NSString *email;
@property (nonatomic, assign, getter = getPassword, setter = setPassword:) NSString *password;
@property (nonatomic, assign, getter = getName, setter = setName:) NSString *name;

-(id)initWithProperties:(NSDictionary<NSString*, id> *)props;

-(NSString *)getUserToken;
-(void)setProperties:(NSDictionary<NSString*, id> *)props;
-(void)addProperties:(NSDictionary<NSString*, id> *)props;
-(NSDictionary<NSString*, id> *)getProperties;
-(void)updateProperties:(NSDictionary<NSString*, id> *)props;
-(id)getProperty:(NSString *)key;
-(void)setProperty:(NSString *)key object:(id)value;
-(void)removeProperty:(NSString *)key;
-(void)removeProperties:(NSArray<NSString*> *)keys;
@end
