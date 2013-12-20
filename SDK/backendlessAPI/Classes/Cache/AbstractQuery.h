//
//  AbstractQuery.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/14/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackendlessCacheProtocol.h"
#import "BackendlessCachePolicy.h"

@interface AbstractQuery : NSObject<BackendlessCacheProtocol>
@property (nonatomic, strong) BackendlessCachePolicy *cachePolicy;
@end
