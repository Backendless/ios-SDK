//
//  BackendlessSimpleQuery.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 8/13/15.
//  Copyright (c) 2015 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_PAGE_SIZE 100
#define DEFAULT_OFFSET 0

@interface BackendlessSimpleQuery : NSObject
@property (strong, nonatomic) NSNumber *pageSize;
@property (strong, nonatomic) NSNumber *offset;

+(id)query;
+(id)query:(int)pageSize offset:(int)offset;
@end
