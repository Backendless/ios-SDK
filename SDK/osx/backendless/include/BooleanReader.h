//
//  BooleanReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 24.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface BooleanReader : NSObject <ITypeReader> {
    BOOL val;
    BOOL initialized;
}

+(id)typeReader;
+(id)typeReader:(BOOL)initvalue;
@end
