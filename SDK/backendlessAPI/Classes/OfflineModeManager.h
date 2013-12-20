//
//  OfflineModeManager.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 12/3/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ISDatabase;
@class BackendlessCollection, BackendlessDataQuery;
@interface OfflineModeManager : NSObject
@property (nonatomic, retain) ISDatabase *dataBase;
@property (nonatomic) BOOL isOfflineMode;
+(OfflineModeManager *)sharedInstance;
-(id)initWithDataBaseName:(NSString *)name;
-(id)initWithDefaultDataBaseName;
-(id)saveObject:(id)object;
-(id)getObjectForId:(NSString *)objectId;
-(void)startUploadData;
-(void)removeObjectWithObjectId:(NSString *)objectId;
@end
