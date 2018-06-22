//
//  ReaderReferenceCache.h
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
#import "IAdaptingType.h"

#define _ReaderReferenceCache_IS_SINGLETON_ 1

@interface ReaderReferenceCache : NSObject {
	NSMutableDictionary	*cache;    
}
+(id)cache;

-(BOOL)hasObject:(id <IAdaptingType>)key;
-(BOOL)hasObject:(id <IAdaptingType>)key type:(Class)type;
-(void)addObject:(id <IAdaptingType>)key object:(id)value;
-(void)addObject:(id <IAdaptingType>)key type:(Class)type object:(id)value;
-(id)getObject:(id <IAdaptingType>)key;
-(id)getObject:(id <IAdaptingType>)key type:(Class)type;
-(void)cleanCache;
@end
