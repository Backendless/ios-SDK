//
//  UndefinedTypeReader.m
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

#import "UndefinedTypeReader.h"
#import "DEBUG.h"
#import "UndefinedType.h"


@implementation UndefinedTypeReader

+(id)typeReader {
	return [[[UndefinedTypeReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC UndefinedTypeReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	[DebLog logN:@"UndefinedTypeReader -> NULL"];
	
	return [UndefinedType objectType];
}

@end
