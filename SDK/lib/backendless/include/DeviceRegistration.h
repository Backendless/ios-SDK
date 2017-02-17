//
//  DeviceRegistration.h
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

@interface DeviceRegistration : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *deviceToken;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSString *osVersion;
@property (strong, nonatomic) NSDate *expiration;
@property (strong, nonatomic) NSArray<NSString *> *channels;

-(BOOL)addChannel:(NSString *)channel;
@end
