//
//  BETableView.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <UIKit/UIKit.h>
@class Fault, BackendlessGeoQuery, DataQueryBuilder;
@interface BETableView : UITableView

-(id)getDataForIndexPath:(NSIndexPath *)indexPath;

-(void)find:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuiler;
-(void)find:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuiler responder:(id)responder;
-(void)find:(Class)entity queryBuilder:(DataQueryBuilder *)queryBuiler response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)getPoints:(BackendlessGeoQuery *)query;
-(void)relativeFind:(BackendlessGeoQuery *)query;
-(void)getPoints:(BackendlessGeoQuery *)query responder:(id)responder;
-(void)relativeFind:(BackendlessGeoQuery *)query responder:(id)responder;
-(void)getPoints:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)relativeFind:(BackendlessGeoQuery *)query response:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)nextPage;
-(void)nextPageAsync:(id)responder;
-(void)nextPageAsync:(void(^)(NSArray *))responseBlock error:(void(^)(Fault *))errorBlock;

-(void)removeAllObjects;
@end
