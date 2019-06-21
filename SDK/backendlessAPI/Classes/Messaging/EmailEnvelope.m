//
//  EmailEnvelope.m
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

#import "EmailEnvelope.h"

@implementation EmailEnvelope

-(instancetype)init {
    if (self = [super init]) {
        self.to = [NSArray<NSString *> new];
        self.cc = [NSArray<NSString *> new];
        self.bcc = [NSArray<NSString *> new];
    }
    return self;
}

-(void)addTo:(NSArray<NSString *> *)to {
    NSMutableArray *mutableTo = [NSMutableArray arrayWithArray:self.to];
    [mutableTo addObjectsFromArray:to];
    self.to = mutableTo;
}

-(void)addCc:(NSArray<NSString *> *)cc {
    NSMutableArray *mutableCc = [NSMutableArray arrayWithArray:self.cc];
    [mutableCc addObjectsFromArray:cc];
    self.cc = mutableCc;
}

-(void)addBcc:(NSArray<NSString *> *)bcc {
    NSMutableArray *mutableBcc = [NSMutableArray arrayWithArray:self.bcc];
    [mutableBcc addObjectsFromArray:bcc];
    self.bcc = mutableBcc;
}

@end
