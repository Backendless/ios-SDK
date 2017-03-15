//
//  ErrMessage.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/14/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ErrMessage.h"


@implementation ErrMessage
@synthesize rootCause, faultString, faultCode, extendedData, faultDetail;

-(id)init {	
	if ( (self=[super init]) ) {
        rootCause = nil;
        faultString = nil;
        faultCode = @"Server.Processing";
        extendedData = nil;
        faultDetail = nil;
        //
        isError = YES;
	}
	
	return self;
}

@end
