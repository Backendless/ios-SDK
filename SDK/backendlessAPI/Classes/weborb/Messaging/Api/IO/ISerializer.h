//
//  ISerializer.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@protocol ISerializer <NSObject>
-(void)serialize:(id)obj;
-(void)serialize:(id)obj version:(int)ver;
-(int)getVersion;
@end
