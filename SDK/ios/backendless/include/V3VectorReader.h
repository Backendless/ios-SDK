//
//  V3VectorReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface V3VectorReader : NSObject <ITypeReader> {
    int _type;
}
+(id)typeReader:(int)type;
@end
