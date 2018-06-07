//
//  NumberWriter.m
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

#import "NumberWriter.h"
#import "DEBUG.h"
#import "IProtocolFormatter.h"

#include <math.h>


@implementation NumberWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[NumberWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
	
	if (!obj || !writer)
		return;
    
	NSNumber *data = (NSNumber *)obj;
    char dataType = [data objCType][0];
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"NumberWriter  ----  NSNumber->objCType: '%c', data = %@ [%@]", dataType, data, [self isBoolNumber:data]?@"BOOL":@"NUM"];
    
    if (dataType == 'c' || dataType == 'B' || dataType == 'C')
        [writer writeBoolean:[data boolValue]];
    else
        if (dataType == 'f')
            [writer writeDouble:[[NSString stringWithFormat:@"%g", [data floatValue]] doubleValue]];
        else
            if (dataType == 'd')
                [writer writeDouble:[data doubleValue]];
            else
                [writer writeInteger:[data doubleValue]];
}

-(BOOL)isBoolNumber:(NSNumber *)num {
    CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
    CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
    return numID == boolID;
}

@end
