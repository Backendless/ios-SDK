//
//  V3DateReader.m
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

#import "V3DateReader.h"
#import "DEBUG.h"
#import "DateType.h"


@implementation V3DateReader

+(id)typeReader {
	return [[[V3DateReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3DateReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0)
        return [parseContext getReference:(refId >> 1)];

    double dateTime = [reader readDouble];	
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:dateTime/1000];
	[DebLog logN:@"V3DateReader -> %@", date];
    DateType *dateType = [DateType objectType:date];
    [parseContext addReference:dateType];
	return dateType;
}

@end
