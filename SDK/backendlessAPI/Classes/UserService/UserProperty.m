//
//  UserProperty.m
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

#import "UserProperty.h"
#import "DEBUG.h"

@implementation UserProperty

-(id)init {
    if (self = [super init]) {
        self.identity = nil;
    }
    return self;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC UserProperty"];
    [_identity release];
    [super dealloc];
}

-(BOOL)isIdentity {
    return _identity && [_identity boolValue];
}

-(void)isIdentity:(BOOL)identity {
    self.identity = @(identity);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@\n<UserProperty> identity: %@", [super description], [self isIdentity]?@"YES":@"NO"];
}

@end
