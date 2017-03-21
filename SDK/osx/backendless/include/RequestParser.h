//
//  RequestParser.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"
#import "FlashorbBinaryReader.h"
#import "ParseContext.h"
#import "Request.h"


@interface RequestParser : NSObject {

}
+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader;
+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader version:(int)version;
+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext;
+(Request *)readMessage:(FlashorbBinaryReader *)reader;
@end
