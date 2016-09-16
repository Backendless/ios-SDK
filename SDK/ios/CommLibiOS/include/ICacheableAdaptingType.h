//
//  ICacheableAdaptingType.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/5/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IAdaptingType.h"
#import "ReaderReferenceCache.h"


@protocol ICacheableAdaptingType <IAdaptingType>
-(id)defaultAdapt:(ReaderReferenceCache *)refCache;
-(id)adapt:(Class)type cache:(ReaderReferenceCache *)refCache;
-(id <IAdaptingType>)getCacheKey;
@end
