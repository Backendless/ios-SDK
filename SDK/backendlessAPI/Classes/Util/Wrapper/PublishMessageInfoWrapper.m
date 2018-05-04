//
//  PublishMessageInfoWrapper.m
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

#import "PublishMessageInfoWrapper.h"
#import "Backendless.h"

@implementation PublishMessageInfoWrapper

+(instancetype)sharedInstance {
    static PublishMessageInfoWrapper *sharedPublishMessageInfoWrapper;
    @synchronized(self) {
        if (!sharedPublishMessageInfoWrapper)
            sharedPublishMessageInfoWrapper = [PublishMessageInfoWrapper new];
    }
    return sharedPublishMessageInfoWrapper;
}

-(void(^)(PublishMessageInfo *))wrapResponseBlock:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    void(^wrappedBlock)(PublishMessageInfo *) = ^(PublishMessageInfo *messageInfo) {
        if ([messageInfo.message isKindOfClass:[classType class]]) {
            responseBlock(messageInfo.message);
        }
        else {
            errorBlock([Fault fault:@"Received incorrect object type" detail:[NSString stringWithFormat:@"Expected: %@, received: %@", NSStringFromClass(classType), [messageInfo.message class]]]);
        }
    };
    return wrappedBlock;
}

-(void(^)(PublishMessageInfo *))wrapResponseBlockToCustomObject:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock class:(Class)classType {
    NSString *classTypeName = [backendless.persistenceService getEntityName:NSStringFromClass(classType)];
    void(^wrappedBlock)(PublishMessageInfo *) = ^(PublishMessageInfo *messageInfo) {
        if ([messageInfo.message isKindOfClass:[NSDictionary class]]) {
            NSDictionary *message = messageInfo.message;
            if ([message valueForKey:@"___class"]) {
                NSString *className = [message valueForKey:@"___class"];
                if ([className isEqualToString:classTypeName]) {
                    id resultObject = [classType new];
                    for (NSString *field in [message allKeys]) {
                        if (![field isEqualToString:@"___class"] && [resultObject respondsToSelector:NSSelectorFromString(field)]) {
                            [resultObject setValue:[message valueForKey:field] forKey:field];                                         }
                    }
                    responseBlock(resultObject);
                }
                else {
                    errorBlock([Fault fault:@"Received incorrect object type" detail:[NSString stringWithFormat:@"Expected: %@, received: %@", classTypeName, [messageInfo.message class]]]);
                }
            }      
        }
        else {
            errorBlock([Fault fault:@"Received incorrect object type" detail:[NSString stringWithFormat:@"Expected: %@, received: %@", NSStringFromClass(classType), [messageInfo.message class]]]);
        }
    };
    return wrappedBlock;
}

@end
