//
//  BackendlessCollection.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <Foundation/Foundation.h>

@class HashMap, Fault;
@protocol IResponder;

@interface BackendlessCollection : NSObject {
    
    NSArray     *data;
    Class       type;
    NSInteger   aTotalObjects;
    NSInteger   aOffset;
    NSInteger   pageSize;
    HashMap     *cachedData;
}
@property (strong, nonatomic) id query;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic, getter = getEntityName, setter = setEntityName:) NSString *entityName;
@property (strong, nonatomic, getter = getTotalObjects, setter = setTotalObjects:) NSNumber *totalObjects;
@property (strong, nonatomic, getter = getOffset, setter = setOffset:) NSNumber *offset;

-(id)init:(BOOL)isCaching;

-(Class)type;
-(void)type:(Class)_type;
-(NSInteger)valTotalObjects;
-(NSInteger)valOffset;
-(void)offset:(NSInteger)_offset;
-(void)nextPageOffset;
-(void)previousPageOffset;
-(NSInteger)valPageSize;
-(void)pageSize:(NSInteger)_pageSize;

-(void)setCaching:(BOOL)isCaching;
-(NSArray *)getCurrentPage;
-(void)cleanCache;

// sync methods with fault return (as exception)
-(BackendlessCollection *)nextPage;
-(BackendlessCollection *)nextPage:(BOOL)forceUpdate;
-(BackendlessCollection *)previousPage;
-(BackendlessCollection *)previousPage:(BOOL)forceUpdate;
-(BackendlessCollection *)getPage:(NSInteger)_offset;
-(BackendlessCollection *)getPage:(NSInteger)_offset update:(BOOL)forceUpdate;
-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize;
-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate;
-(BackendlessCollection *)removeAll;

// sync methods with fault option
-(BackendlessCollection *)nextPageFault:(Fault **)fault;
-(BackendlessCollection *)nextPage:(BOOL)forceUpdate error:(Fault **)fault;
-(BackendlessCollection *)previousPageFault:(Fault **)fault;
-(BackendlessCollection *)previousPage:(BOOL)forceUpdate error:(Fault **)fault;
-(BackendlessCollection *)getPage:(NSInteger)_offset error:(Fault **)fault;
-(BackendlessCollection *)getPage:(NSInteger)_offset update:(BOOL)forceUpdate error:(Fault **)fault;
-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize error:(Fault **)fault;
-(BackendlessCollection *)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate error:(Fault **)fault;

// async methods with responder
-(void)nextPageAsync:(id <IResponder>)responder;
-(void)nextPage:(BOOL)forceUpdate responder:(id <IResponder>)responder;
-(void)previousPageAsync:(id <IResponder>)responder;
-(void)previousPage:(BOOL)forceUpdate responder:(id <IResponder>)responder;
-(void)getPage:(NSInteger)_offset responder:(id <IResponder>)responder;
-(void)getPage:(NSInteger)_offset update:(BOOL)forceUpdate responder:(id <IResponder>)responder;
-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize responder:(id <IResponder>)responder;
-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate responder:(id <IResponder>)responder;
-(void)removeAll:(id <IResponder>)responder;

// async methods with block-based callbacks
-(void)nextPageAsync:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)nextPage:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)previousPageAsync:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)previousPage:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPage:(NSInteger)_offset response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPage:(NSInteger)_offset update:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)getPage:(NSInteger)_offset pageSize:(NSInteger)_pageSize update:(BOOL)forceUpdate response:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeAll:(void(^)(BackendlessCollection *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
