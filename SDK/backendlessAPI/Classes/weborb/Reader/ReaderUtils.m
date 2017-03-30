//
//  ReaderUtils.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ReaderUtils.h"

@implementation ReaderUtils

+(NSString *)readString:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int len = [reader readVarInteger];
    if (len % 2 == 0)
        return [parseContext getStringReference:(len >> 1)];
        
    NSString *str = nil;
    len = len >> 1;
    char *utf8str = [reader readUTF:len];
    if (utf8str) {
        str = [NSString stringWithUTF8String:utf8str];
        //NSLog(@"************> ReaderUtils -> readString: '%@' [%s]", str, utf8str);
        free(utf8str);
    }
    
    if (str && str.length)
        [parseContext addStringReference:str];
    
	return str;
}

@end
