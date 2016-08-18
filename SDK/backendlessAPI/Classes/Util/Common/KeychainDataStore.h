//
//  KeychainDataStore.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 8/18/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainDataStore : NSObject
@property (strong, nonatomic, readonly) NSString *service;
@property (strong, nonatomic, readonly) NSString *group;

-(id)initWithService:(NSString *)service withGroup:(NSString *)group;

-(BOOL)save:(NSString *)key data:(NSData *)data;
-(NSData *)get:(NSString*)key;
-(BOOL)update:(NSString *)key data:(NSData *)data;
-(BOOL)remove:(NSString *)key;

@end
