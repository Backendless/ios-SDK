//
//  LoadRelationsQueryBuilder.h
//  backendlessAPI
//
//  Created by Admin on 12/6/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedQueryBuilder.h"

@interface LoadRelationsQueryBuilder : NSObject

-(instancetype)initWithClass:(Class)relationType;

-(BackendlessDataQuery *)build;
-(instancetype) setGetRelationName:(NSString*) relationName;
-(instancetype) setGetPageSize:(int)pageSize;
-(instancetype) setGetOffset:(int)offset;
-(instancetype) prepareNextPage;
-(instancetype) preparePreviousPage;
-(NSMutableArray<NSString*> *)getRelationType;

@end
