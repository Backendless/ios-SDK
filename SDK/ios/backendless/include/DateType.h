//
//  DateType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"


@interface DateType : NSObject <IAdaptingType> {
    NSDate *dateObj;
}
+(id)objectType:(NSDate *)date;
@end
