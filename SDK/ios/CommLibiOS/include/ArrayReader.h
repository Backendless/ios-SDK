//
//  ArrayReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 13.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface ArrayReader : NSObject <ITypeReader> {

}

+(id)typeReader;
@end
