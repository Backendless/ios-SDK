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

#define _OBJECT_ID_WITHOUT_SETTER_GETTER_ 0

#define BACKENDLESS_EMAIL_KEY @"email"
#define BACKENDLESS_NAME_KEY @"name"
#define BACKENDLESS_PASSWORD_KEY @"password"
#define BACKENDLESS_ID_KEY @"id"
#define BACKENDLESS_USER_TOKEN @"user-token"

@interface BackendlessUser : NSObject

#if _OBJECT_ID_WITHOUT_SETTER_GETTER_
@property (nonatomic, retain) NSString *objectId;
#else
@property (nonatomic, assign, getter = getObjectId, setter = seObjectId:) NSString *objectId;
#endif
@property (nonatomic, assign, getter = getEmail, setter = setEmail:) NSString *email;
@property (nonatomic, assign, getter = getPassword, setter = setPassword:) NSString *password;
@property (nonatomic, assign, getter = getName, setter = setName:) NSString *name;
@property (nonatomic, assign, getter = getUserId) NSString *userId;
@property (nonatomic, assign, getter = getUserToken) NSString *userToken;

-(id)initWithProperties:(NSDictionary *)props;

-(void)setProperties:(NSDictionary *)props;
-(NSMutableDictionary *)getProperties;
-(void)updateProperties:(NSDictionary *)props;
-(id)getProperty:(NSString *)key;
-(void)setProperty:(NSString *)key object:(id)value;
-(void)removeProperty:(NSString *)key;
-(void)removeProperties:(NSArray *)keys;
@end
