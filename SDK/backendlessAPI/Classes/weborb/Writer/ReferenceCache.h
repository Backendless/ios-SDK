//
//  ReferenceCache.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 29.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReferenceCache : NSObject
-(void)reset;
-(void)addObject:(id)obj;
-(void)addString:(NSString *)obj;
-(int)getStringId:(NSString *)obj;
-(int)getObjectId:(id)obj;
-(int)getId:(id)obj;
@end
