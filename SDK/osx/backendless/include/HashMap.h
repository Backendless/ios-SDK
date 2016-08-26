//
//  HashMap.h
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


@interface HashMap : NSObject
@property (nonatomic, strong, readonly) NSMutableDictionary	*node;

-(id)initWithNode:(NSDictionary *)dict;

-(BOOL)push:(NSString *)key withObject:(id)it;
-(BOOL)add:(NSString *)key withObject:(id)it;
-(id)get:(NSString *)key;
-(BOOL)pop:(NSString *)key withObject:(id)it;
-(BOOL)del:(NSString *)key;
-(NSUInteger)count;
-(NSArray *)keys;
-(NSArray *)values;
-(void)clear;
-(Class)hashClass;
@end
