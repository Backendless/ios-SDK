//
//  UndefinedType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"


@interface UndefinedType : NSObject <IAdaptingType> {
    
}
+(id)objectType;
@end
