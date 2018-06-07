//
//  NamedObjectReader.m
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

#import "NamedObjectReader.h"
#import "DEBUG.h"
#import "NamedObject.h"
#import "AnonymousObjectReader.h"


@implementation NamedObjectReader

+(id)typeReader {
	return [[[NamedObjectReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC NamedObjectReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	NSString *objectName = [reader readString];
	
	[DebLog log:_ON_READERS_LOG_ text:@"NamedObjectReader -> read:context: objectName = '%@'", objectName];
		
	AnonymousObjectReader *objectReader = [AnonymousObjectReader typeReader];
	return [NamedObject objectType:objectName withObject:[objectReader read:reader context:parseContext]];
}

@end
