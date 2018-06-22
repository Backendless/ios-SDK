//
//  BackendlessSimpleQuery.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BackendlessSimpleQuery.h"
#import "DEBUG.h"

@implementation BackendlessSimpleQuery

-(id)init {
    if (self = [super init]) {
        self.pageSize = @(DEFAULT_PAGE_SIZE);
        self.offset = @(DEFAULT_OFFSET);
    }
    return self;
}

+(id)query {
    return [[BackendlessSimpleQuery new] autorelease];
}

+(id)query:(int)pageSize offset:(int)offset {
    BackendlessSimpleQuery *_query = [BackendlessSimpleQuery query];
    _query.pageSize = @(pageSize);
    _query.offset = @(offset);
    return _query;
}

-(void)dealloc {
    [DebLog logN:@"DEALLOC BackendlessSimpleQuery"];
    [_pageSize release];
    [_offset release];    
    [super dealloc];
}

@end
