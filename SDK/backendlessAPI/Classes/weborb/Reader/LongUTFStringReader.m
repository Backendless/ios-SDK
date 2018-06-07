//
//  LongUTFStringReader.m
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

#import "LongUTFStringReader.h"
#import "DEBUG.h"
#import "ByteArrayType.h"
#import "StringType.h"
#import "BinaryCodec.h"


@implementation LongUTFStringReader

+(id)typeReader {
	return [[[LongUTFStringReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC LongUTFStringReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    BOOL isString = YES; // output: YES - NSString, NO - NSData 
    
    NSString *str;
    int len = [reader readUInteger];
    char *utf8str = [reader readChars:len];
    if (utf8str) {
        str = [NSString stringWithUTF8String:utf8str];
        free(utf8str);
    }
    else
        str = [NSString string];
	
	[DebLog logN:@"LongUTFStringReader -> '%@'", str];
    
	return (isString) ? [StringType objectType:str] : [ByteArrayType objectType:[BEBase64 decode:str]];
}

@end
