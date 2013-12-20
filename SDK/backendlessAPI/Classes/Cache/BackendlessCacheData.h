//
//  BackendlessCacheData.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackendlessCollection.h"

typedef void(^BackendlessCacheDataSaveCompletion)(BOOL done);

@interface BackendlessCacheData : NSObject
@property (nonatomic, strong) id data;
@property (nonatomic, strong) NSNumber *timeToLive;
@property (nonatomic, strong) NSNumber *priority;
@property (nonatomic, strong, readonly) NSString *file;

-(void)increasePriority;
-(void)decreasePriority;
-(NSInteger)valPriority;
-(void)saveOnDiscCompletion:(BackendlessCacheDataSaveCompletion)block;
-(id)dataFromDisc;
-(id)initWithCache:(BackendlessCacheData *)cache;
-(void)remove;
-(void)removeFromDisc;
@end
