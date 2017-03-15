//
//  ReaderUtils.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ReaderUtils.h"
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif


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
        
#if 0 // move to FlashorbBinaryReader readUTF method
        /* convert emoji - http://stackoverflow.com/questions/34151138/convert-cesu-8-to-utf-8-with-high-performance
         $regex = '@(\xED[\xA0-\xAF][\x80-\xBF]\xED[\xB0-\xBF][\x80-\xBF])@';
         $in[2] += 1;
         0xF0 | (($in[2] & 0x1C) >> 2),
         0x80 | (($in[2] & 0x03) << 4) | (($in[3] & 0x3C) >> 2),
         0x80 | (($in[3] & 0x03) << 4) | ($in[5] & 0x0F),
         $in[6]
         
         ED       A0-AF    80-BF    ED       B0-BF    80-BF
         11101101 1010aaaa 10bbbbbb 11101101 1011cccc 10dddddd
         to
         F0-F4    80-BF    80-BF    80-BF
         11110oaa 10aabbbb 10bbcccc 10dddddd    // o is "overflow" bit
         */
        
        if (!str) {
            
            //NSData *d = [NSData dataWithBytes:utf8str length:len+1];
            //NSLog(@"<<<<< [%@]", d);
            
            int cin = 0;
            int cout = 0;
            while (cin < len) {
                
                if (utf8str[cin] == (char)0xED) {
                    
                    if ((cin + 5 < len) && (utf8str[cin+3] == (char)0xED)) {
                        utf8str[cin+1] += 1;
                        utf8str[cout++] = (char)(0xF0 | ((utf8str[cin+1] & 0x1C) >> 2));
                        utf8str[cout++] = (char)(0x80 | ((utf8str[cin+1] & 0x03) << 4) | ((utf8str[cin+2] & 0x3C) >> 2));
                        utf8str[cout++] = (char)(0x80 | ((utf8str[cin+2] & 0x03) << 4) | (utf8str[cin+4] & 0x0F));
                        utf8str[cout++] = utf8str[cin+5];
                        cin += 6;
                    }
                    else {
                        break;
                    }
                    
                }
                else {
                    utf8str[cout++] = utf8str[cin++];
                }
            }
            utf8str[cout] = 0;
            
            str = [NSString stringWithUTF8String:utf8str];
            
            //NSData *d1 = [NSData dataWithBytes:utf8str length:cout];
            //NSLog(@"<<<<< [%@] -> '%@'", d1, str);
        }
        
#endif
        
        //NSLog(@"************> ReaderUtils -> readString: '%@' [%s]", str, utf8str);
        free(utf8str);
    }
    
    if (str && str.length)
        [parseContext addStringReference:str];
    
	return str;
}

@end
