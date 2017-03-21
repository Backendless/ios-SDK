//
//  AnonymousObjectReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"

@interface AnonymousObjectReader : NSObject <ITypeReader> {

}
+(id)typeReader;
@end
