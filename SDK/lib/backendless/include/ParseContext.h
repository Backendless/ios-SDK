//
//  ParseContext.h
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

@interface ParseContext : NSObject {
	NSMutableArray		*references;
	NSMutableArray		*stringReferences;
	NSMutableArray		*classInfos;
	NSMutableDictionary	*cachedContext;
	int					_version;
}

-(id)initWithVersion:(int)version;
-(ParseContext *)getCachedContext:(int)version;
-(void)addReference:(id <IAdaptingType>)type;
-(id <IAdaptingType>)getReference:(int)pointer;
-(void)addReference:(id <IAdaptingType>)type atIndex:(int)index;
-(void)addStringReference:(NSString *)refStr;
-(NSString *)getStringReference:(int)index;
-(void)addClassInfoReference:(id)val;
-(id)getClassInfoReference:(int)index;
-(int)getVersion;

@end
