//
//  IOSPushTemplate.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
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
#import "ButtonTemplate.h"

@interface IOSPushTemplate : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *alertTitle;
@property (strong, nonatomic) NSString *alertSubtitle;
@property (nonatomic) int badge;
@property (strong, nonatomic) NSString *sound;
@property (strong, nonatomic) NSString *attachmentUrl;
@property (nonatomic) int mutableContent;
@property (nonatomic) int contentAvailable;
@property (strong, nonatomic) ButtonTemplate *buttonTemplate;

@end
