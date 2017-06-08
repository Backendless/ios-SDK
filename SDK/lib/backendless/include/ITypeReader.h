//
//  ITypeReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IAdaptingType.h"
#import "FlashorbBinaryReader.h"
#import "ParseContext.h"

#define _ADAPT_DURING_PARSING_ 0
#define _ON_RESOLVING_ABSENT_PROPERTY_ 1
#define _ON_READERS_LOG_ NO

@protocol ITypeReader <NSObject>
-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext;
@end
