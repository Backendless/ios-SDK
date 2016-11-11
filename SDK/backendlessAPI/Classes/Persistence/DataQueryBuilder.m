//
//  DataQueryBuilder.m
//  backendlessAPI
//
//  Created by Slava Vdovichenko on 11/10/16.
//  Copyright © 2016 BACKENDLESS.COM. All rights reserved.
//

#import "DataQueryBuilder.h"
#import "DEBUG.h"
#import "PagedQueryBuilder.h"
#import "QueryOptionsBuilder.h"

@interface DataQueryBuilder ()
@property (strong, nonatomic) PagedQueryBuilder *pagedQueryBuilder;
@property (strong, nonatomic) QueryOptionsBuilder *queryOptionsBuilder;
@property (strong, nonatomic) NSMutableArray<NSString *> *properties;
@property (strong, nonatomic) NSString *whereClause;
@end

@implementation DataQueryBuilder

-(instancetype)init {
    if ( (self=[super init]) ) {
        self.pagedQueryBuilder = [[PagedQueryBuilder alloc] init:self];
        self.queryOptionsBuilder = [[QueryOptionsBuilder alloc] init:self];
        self.properties = [NSMutableArray new];
        self.whereClause = nil;
    }
    
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC DataQueryBuilder"];
    
    [self.pagedQueryBuilder release];
    [self.queryOptionsBuilder release];
    [self.properties removeAllObjects];
    [self.properties release];
    [self.whereClause release];
    
    [super dealloc];
}

@end
