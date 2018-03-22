//
//  ArrayType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 13.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICacheableAdaptingType.h"


@interface ArrayType : NSObject <ICacheableAdaptingType> {
	NSArray *arrayObject;
}

+(id)objectType:(NSArray *)data;
-(NSArray *)getArray;

@end
