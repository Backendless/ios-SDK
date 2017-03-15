//
//  V3ReferenceCache.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReferenceCache.h"

@interface V3ReferenceCache : ReferenceCache
-(void)addToTraitsCache:(NSString *)className;
-(int)getTraitsId:(NSString *)className;
@end
