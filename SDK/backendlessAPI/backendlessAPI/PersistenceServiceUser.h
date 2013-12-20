//
//  PersistenceUser.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 5/14/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//


@interface PersistenceServiceAddress : NSObject

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *objectId;

@end

@interface PersistenceServiceUser : NSObject
@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) PersistenceServiceAddress *address;
@end