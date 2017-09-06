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

+(instancetype)ofMap;
+(instancetype)of:(Class)relationType;

-(BackendlessDataQuery *)build;
-(instancetype) setRelationName:(NSString*) relationName;
-(instancetype) setPageSize:(int)pageSize;
-(instancetype) setOffset:(int)offset;
-(instancetype) prepareNextPage;
-(instancetype) preparePreviousPage;
-(NSMutableArray<NSString*> *)getRelationType;

@end
