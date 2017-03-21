//
//  ReaderReferenceCache.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/20/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
