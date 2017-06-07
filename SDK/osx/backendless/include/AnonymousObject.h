//
//  AnonymousObject.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICacheableAdaptingType.h"

@interface AnonymousObject : NSObject <ICacheableAdaptingType> {
	NSMutableDictionary	*properties;
}

@property (nonatomic, assign) NSMutableDictionary *properties;

+(id)objectType;
+(id)objectType:(NSMutableDictionary *)dictionary;

@end
