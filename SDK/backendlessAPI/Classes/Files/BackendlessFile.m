//
//  BackendlessFile.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BackendlessFile.h"
#import "Backendless.h"

@implementation BackendlessFile

-(id)init {
	if ( (self=[super init]) ) {
        _fileURL = nil;
	}
	
	return self;
}

-(id)initWithUrl:(NSString *)url {
	if ( (self=[super init]) ) {
        _fileURL = [url retain];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BackendlessFile"];
    
    [_fileURL release];
	
	[super dealloc];
}

+(id)file:(NSString *)url {
    return [[[BackendlessFile alloc] initWithUrl:url] autorelease];
}

#pragma mark -
#pragma mark Public Methods

// sync

-(void)remove {
    [backendless.fileService remove:_fileURL];
}

// async
-(void)removeWithResponder:(id <IResponder>)responder {
    [backendless.fileService remove:_fileURL responder:responder];
}

-(void)remove:(void (^)(id))responseBlock error:(void (^)(id))errorBlock {
    [backendless.fileService remove:_fileURL response:responseBlock error:errorBlock];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<BackendlessFile> -> fileURL: %@", _fileURL];
}

@end
