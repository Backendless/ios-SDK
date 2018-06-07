//
//  ReaderUtils.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
