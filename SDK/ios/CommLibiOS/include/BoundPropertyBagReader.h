//
//  BoundPropertyBagReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 16.05.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface BoundPropertyBagReader : NSObject <ITypeReader> {
    
}

+(id)typeReader;
@end
