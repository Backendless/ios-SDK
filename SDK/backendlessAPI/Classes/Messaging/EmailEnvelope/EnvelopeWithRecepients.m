//
//  EnvelopeWithRecipients.m
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

#import "EnvelopeWithRecipients.h"

@interface EnvelopeWithRecipients() {
    NSMutableArray<NSString *> *toAddresses;
    NSMutableArray<NSString *> *ccAddresses;
    NSMutableArray<NSString *> *bccAddresses;
}
@end

@implementation EnvelopeWithRecipients

-(instancetype)init {
    if (self = [super init]) {
        toAddresses = [NSMutableArray<NSString *> new];
        ccAddresses = [NSMutableArray<NSString *> new];
        bccAddresses = [NSMutableArray<NSString *> new];
    }
    return self;
}

-(void)addTo:(NSArray<NSString *> *)to {
    [toAddresses addObjectsFromArray:to];
}

-(void)setTo:(NSArray<NSString *> *)to {
    toAddresses = [NSMutableArray arrayWithArray:to];
}

-(NSArray<NSString *> *)getTo {
    return toAddresses;
}

-(void)addCc:(NSArray<NSString *> *)cc {
    [ccAddresses addObjectsFromArray:cc];
}

-(void)setCc:(NSArray<NSString *> *)cc {
    ccAddresses = [NSMutableArray arrayWithArray:cc];
}

-(NSArray<NSString *> *)getCc {
    return ccAddresses;
}

-(void)addBcc:(NSArray<NSString *> *)bcc {
    [bccAddresses addObjectsFromArray:bcc];
}

-(void)setBcc:(NSArray<NSString *> *)bcc {
    bccAddresses = [NSMutableArray arrayWithArray:bcc];
}

-(NSArray<NSString *> *)getBcc {
    return bccAddresses;
}

@end
