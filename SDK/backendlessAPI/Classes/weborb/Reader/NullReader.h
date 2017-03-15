//
//  NullReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"

@interface NullReader : NSObject <ITypeReader> {

}
+(id)typeReader;
@end
