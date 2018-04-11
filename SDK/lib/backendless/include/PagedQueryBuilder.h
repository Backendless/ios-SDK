//
//  PagedQueryBuilder.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/9/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BackendlessDataQuery;

@protocol IPagedQueryBuilder <NSObject>

-(id)setPageSize:(int)pageSize;
-(id)setOffset:(int)offset;
-(id)prepareNextPage;
-(id)preparePreviousPage;

@end

@interface PagedQueryBuilder : NSObject <IPagedQueryBuilder>

-(instancetype)init:(id)builder;
-(BackendlessDataQuery *)build;

@end
