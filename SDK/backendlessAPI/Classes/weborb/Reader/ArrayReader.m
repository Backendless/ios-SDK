//
//  ArrayReader.m
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

#import "ArrayReader.h"
#import "DEBUG.h"
#import "ArrayType.h"
#import "RequestParser.h"


@implementation ArrayReader

+(id)typeReader {
	return [[[ArrayReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ArrayReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSMutableArray *array = [NSMutableArray array];
	ArrayType *arrayType = [ArrayType objectType:array];
	[parseContext addReference:arrayType];
	
	int length = [reader readInteger];
	
	[DebLog logN:@"ArrayReader -> length = %d", length];
	
	for (int i = 0; i < length; i++) {
		id obj = [RequestParser readData:reader context:parseContext];
		if (obj) {
#if _ADAPT_DURING_PARSING_
            obj = [obj defaultAdapt];
            if (!obj) obj = [NSNull null];
#endif
			[array addObject:obj];
        }
	}
	
	[DebLog log:@"ArrayReader -> array.count = %d, array = %@", [array count], array];
	
	return arrayType;
}

@end
