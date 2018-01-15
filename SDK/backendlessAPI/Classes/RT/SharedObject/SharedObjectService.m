//
//  SharedObjectService.m
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

#import "SharedObjectService.h"
#import "RTFactory.h"

@implementation SharedObjectService

+(instancetype)sharedInstance {
    static SharedObjectService *_sharedObjectService;
    @synchronized(self) {
        if (!_sharedObjectService)
            _sharedObjectService = [SharedObjectService new];
    }
    return _sharedObjectService;
}

-(SharedObject *)connect:(NSString *)name {
    SharedObject *sharedObject = [rtFactory getSharedObject:name];
    [sharedObject connect];
    return sharedObject;
}

@end
