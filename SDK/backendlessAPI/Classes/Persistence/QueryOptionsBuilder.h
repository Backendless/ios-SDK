//
//  QueryOptionsBuilder.h
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/9/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IQueryOptionsBuilder <NSObject>
-(NSMutableArray<NSString *> *)getSortBy;
-(id)setSortBy:(NSArray<NSString *> *)sortBy;
-(id)addSortBy:(NSString *)sortBy;
-(id)addListSortBy:(NSArray<NSString *> *)sortBy;
-(NSMutableArray<NSString *> *)getRelated;
-(id)setRelated:(NSArray<NSString *> *)related;
-(id)addRelated:(NSString *)related;
-(id)addListRelated:(NSArray<NSString *> *)related;
-(NSNumber *)getRelationsDepth;
-(id)setRelationsDepth:(int)relationsDepth;
@end

@class QueryOptions;

@interface QueryOptionsBuilder : NSObject <IQueryOptionsBuilder>
-(instancetype)init:(id)builder;
-(QueryOptions *)build;
@end
