//
//  V3ByteArrayReader.m
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

#import "V3ByteArrayReader.h"
#import "DEBUG.h"
#import "ArrayType.h"
#import "NumberObject.h"
#import "ByteArrayType.h"


@implementation V3ByteArrayReader

+(id)typeReader {
	return [[[V3ByteArrayReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ByteArrayReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0)
        return [parseContext getReference:(refId >> 1)];
	
    int arraySize = (refId >> 1);
	char *bytes = [reader readChars:arraySize];
    NSData *data = [NSData dataWithBytes:bytes length:arraySize];
    free(bytes);
    
    ByteArrayType *arrayType = [ByteArrayType objectType:data];
    [parseContext addReference:arrayType];
    
    return arrayType;    
}

@end
