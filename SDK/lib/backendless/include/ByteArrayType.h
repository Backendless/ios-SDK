//
//  ByteArrayType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.09.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"

@interface ByteArrayType : NSObject <IAdaptingType> {
    NSData  *dataValue;
}
+(id)objectType:(NSData *)data;
@end
