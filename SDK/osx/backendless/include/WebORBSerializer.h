//
//  WebORBSerializer.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISerializer.h"
#import "FlashorbBinaryWriter.h"


@interface WebORBSerializer : NSObject <ISerializer> {
	FlashorbBinaryWriter	*buffer;
	int						version;
}
@property (nonatomic, assign) FlashorbBinaryWriter *buffer;
@property int version;

-(id)initWithWriter:(FlashorbBinaryWriter *)source;
-(id)initWithWriter:(FlashorbBinaryWriter *)source andVersion:(int)ver;
+(id)writer;
+(id)writer:(FlashorbBinaryWriter *)source;
+(id)writer:(FlashorbBinaryWriter *)source andVersion:(int)ver;
@end
