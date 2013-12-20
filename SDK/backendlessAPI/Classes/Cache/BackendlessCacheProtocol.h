//
//  BackendlessCacheProtocol.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BackendlessCacheProtocol <NSObject>
-(BOOL)isEqualToQuery:(id)query;
@end
