//
//  ParseContext.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
