//
//  CrowdNode.h
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

#import <Foundation/Foundation.h>


@interface CrowdNode : NSObject {
	NSMutableDictionary		*node;		
}
@property (nonatomic, assign, readonly) NSMutableDictionary	*node;

-(BOOL)push:(NSString *)key withObject:(id)it;
-(BOOL)add:(NSString *)key withObject:(id)it;
-(id)get:(NSString *)key;
-(BOOL)pop:(NSString *)key withObject:(id)it;
-(BOOL)del:(NSString *)key;
-(int)count;
-(NSArray *)keys;
-(void)clear;
-(Class)nodeClass;
@end
