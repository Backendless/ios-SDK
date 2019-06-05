//
//  IEmailEnvelope
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

@protocol IEmailEnvelope <NSObject>

-(void)addCc:(NSArray<NSString *> *)cc;
-(void)setCc:(NSArray<NSString *> *)cc;
-(NSArray<NSString *> *)getCc;

-(void)addBcc:(NSArray<NSString *> *)bcc;
-(void)setBcc:(NSArray<NSString *> *)bcc;
-(NSArray<NSString *> *)getBcc;

@end
