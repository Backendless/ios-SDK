//
//  NullType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"

@interface NullType : NSObject <IAdaptingType> {

}
+(id)objectType;
@end
