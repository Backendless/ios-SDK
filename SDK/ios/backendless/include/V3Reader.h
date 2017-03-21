//
//  V3Reader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface V3Reader : NSObject <ITypeReader> {
    
}
+(id)typeReader;
@end
