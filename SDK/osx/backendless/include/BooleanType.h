//
//  BooleanType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 24.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"


@interface BooleanType : NSObject <IAdaptingType> {
    NSNumber    *boolean;
}

+(id)objectType:(BOOL)data;
@end
