//
//  BackendlessQueryFactory.h
//  backendlessAPI
//
//  Created by Vyacheslav Vdovichenko on 9/14/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/***********************************************************************************************************
 * BackendlessQueryFactory singleton accessor: this is how you should ALWAYS get a reference to the Invoker class instance *
 ***********************************************************************************************************/
#define backendlessQueryFactory [BackendlessQueryFactory sharedInstance]

@class BackendlessQuery;

@interface BackendlessQueryFactory : NSObject {
    BackendlessQuery *query;
}
// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(BackendlessQueryFactory *)sharedInstance;
-(BackendlessQuery *)getQuery:(int)offset pageSize:(int)pageSize;
@end
