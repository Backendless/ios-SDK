//
//  BodyHolder.m
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

#import "BodyHolderFactory.h"
#import "DEBUG.h"
#import "IAdaptingType.h"
#import "BodyHolder.h"
#import "ITypeReader.h"


@implementation BodyHolderFactory

+(id)factory {
    return [[[BodyHolderFactory alloc] init] autorelease];
}

#pragma mark -
#pragma mark IArgumentObjectFactory Methods

-(id)createObject:(id <IAdaptingType>)argument {
    
    [DebLog log:_ON_READERS_LOG_ text:@"BodyHolderFactory -> createObject: argument = %@", argument];
    
    BodyHolder *bodyObj = [[[BodyHolder alloc] init] autorelease];
    bodyObj.body = [argument defaultAdapt];
    
    [DebLog log:_ON_READERS_LOG_ text:@"BodyHolderFactory -> createObject: %@", bodyObj];
    
    return bodyObj;
}

@end
