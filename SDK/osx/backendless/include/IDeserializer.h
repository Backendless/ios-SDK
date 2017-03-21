//
//  IDeserializer.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@class ParseContext, FlashorbBinaryReader;

@protocol IDeserializer <NSObject>
-(id)deserialize;
-(id)deserializeAdapted:(BOOL)adapt;
-(int)getVersion;
@optional
-(id)deserialize:(char *)buffer;
-(id)deserialize:(char *)buffer context:(ParseContext *)context;
-(id)deserialize:(char *)buffer adapt:(BOOL)adapt;
-(id)deserialize:(char *)buffer adapt:(BOOL)adapt context:(ParseContext *)context;
-(FlashorbBinaryReader *)getStream;
-(ParseContext *)getContext;
@end
