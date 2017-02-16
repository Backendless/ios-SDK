//
//  BackendlessCacheKey.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
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
#import "BackendlessCacheProtocol.h"
#import "AbstractQuery.h"

@interface BackendlessCacheKey : NSObject<NSCopying>
@property (nonatomic, strong) AbstractQuery *query;
@property (nonatomic, strong) NSString *className;

-(BackendlessCacheKey *)initWithClass:(Class)_class query:(id)query;
-(BackendlessCacheKey *)initWithClassName:(NSString *)className query:(id)query;

+(BackendlessCacheKey *)cacheKeyWithClass:(Class)_class query:(id)query;
+(BackendlessCacheKey *)cacheKeyWithClassName:(NSString *)className query:(id)query;

-(BOOL)isEqual:(id)object;
@end
