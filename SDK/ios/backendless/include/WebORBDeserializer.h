//
//  WebORBDeserializer.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDeserializer.h"
#import "FlashorbBinaryReader.h"

@interface WebORBDeserializer : NSObject <IDeserializer> {
	FlashorbBinaryReader	*buffer;
	ParseContext			*context;
	int						version;
}
@property (nonatomic, assign) FlashorbBinaryReader *buffer;

-(id)initWithReader:(FlashorbBinaryReader *)source;
-(id)initWithReader:(FlashorbBinaryReader *)source andVersion:(int)ver;
+(id)reader:(FlashorbBinaryReader *)source;
+(id)reader:(FlashorbBinaryReader *)source andVersion:(int)ver;
@end
