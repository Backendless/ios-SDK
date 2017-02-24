//
//  ReaderUtils.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashorbBinaryReader.h"
#import "ParseContext.h"


@interface ReaderUtils : NSObject 
+(NSString *)readString:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext;
@end
