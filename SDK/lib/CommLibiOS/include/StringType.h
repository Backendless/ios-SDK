//
//  StringType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"

@interface StringType : NSObject <IAdaptingType> {
	NSString	*stringValue;
}
+(id)objectType:(NSString *)string;
@end
