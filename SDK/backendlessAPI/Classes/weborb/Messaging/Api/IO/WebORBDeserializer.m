//
//  WebORBDeserializer.m
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

#import "WebORBDeserializer.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "RequestParser.h"

@implementation WebORBDeserializer
@synthesize buffer;

-(id)init {
	if ( (self=[super init]) ) {
		version = AMF0;
		buffer = nil;
		context = [[ParseContext alloc] initWithVersion:version];
	}
	
	return self;
}

-(id)initWithReader:(FlashorbBinaryReader *)source {
	if ( (self=[super init]) ) {
		version = AMF0;
		buffer = source;
		context = [[ParseContext alloc] initWithVersion:version];
	}
	
	return self;
}

-(id)initWithReader:(FlashorbBinaryReader *)source andVersion:(int)ver {
	if ( (self=[super init]) ) {
		version = ver;
		buffer = source;
		context = [[ParseContext alloc] initWithVersion:version];
	}
	
	return self;
}

+(id)reader:(FlashorbBinaryReader *)source {
	return [[[WebORBDeserializer alloc] initWithReader:source] autorelease];
}

+(id)reader:(FlashorbBinaryReader *)source andVersion:(int)ver {
	return [[[WebORBDeserializer alloc] initWithReader:source andVersion:ver] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC WebORBDeserializer"];
	
	[context release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods


#pragma mark -
#pragma mark IDeserializer Methods

-(id)deserialize {
    
    [DebLog logN:@"+++ WebORBDeserializer->deserialize +++"];
	
	if (!buffer)
		return nil;
	
	id <IAdaptingType> type = [RequestParser readData:buffer context:context];
    
    [DebLog logN:@"+++ WebORBDeserializer->deserialize: %@", type];
	
    return (type) ? [type defaultAdapt] : nil;
}

-(id)deserializeAdapted:(BOOL)adapt {
	return [self deserialize];
}

-(int)getVersion {
	return version;
}

-(FlashorbBinaryReader *)getStream {
	return buffer;
}

-(ParseContext *)getContext {
	return context;
}

@end
