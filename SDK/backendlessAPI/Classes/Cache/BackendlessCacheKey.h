//
//  BackendlessCacheKey.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

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
