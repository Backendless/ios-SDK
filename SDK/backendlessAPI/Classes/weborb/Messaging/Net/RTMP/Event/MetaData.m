//
//  MetaData.m
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


#import "MetaData.h"
#import "DEBUG.h"
#import "RTMPConstants.h"


@implementation MetaData
@synthesize dataSet = _dataSet, eventName = _eventName, metadata = _metadata, object = _object;

-(id)init {
	if ( (self=[super initWithType:STREAM_DATA]) ) {
        _dataSet = [[NSString alloc] initWithString:SET_DATA_FRAME];
        _eventName = [[NSString alloc] initWithString:ON_METADATA];
		_metadata = nil;
        _object = nil;
	}
	
	return self;
}

-(id)initWithMetadata:(NSDictionary *)metadata {
	if ( (self=[super initWithType:STREAM_DATA]) ) {
        _dataSet = [[NSString alloc] initWithString:SET_DATA_FRAME];
        _eventName = [[NSString alloc] initWithString:ON_METADATA];
		_metadata = [metadata retain];
        _object = nil;
	}
	
	return self;
}

-(id)initWithObject:(id)object {
	if ( (self=[super initWithType:STREAM_DATA]) ) {
        _dataSet = [[NSString alloc] initWithString:SET_DATA_FRAME];
        _eventName = [[NSString alloc] initWithString:ON_METADATA];
		_metadata = nil;
        _object = [object retain];
	}
	
	return self;    
}


-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MetaData"];
    
    [_dataSet release];
    [_eventName release];
    [_metadata release];
    [_object release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(NSString *)toString {
	return [self description];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<MetaData> dataSet: %@, eventName: %@, metadata: %@", _dataSet, _eventName, _metadata];
}

#pragma mark -
#pragma mark IRTMPEvent Methods

-(uint)getDataType {
	return TYPE_NOTIFY;
}

@end
