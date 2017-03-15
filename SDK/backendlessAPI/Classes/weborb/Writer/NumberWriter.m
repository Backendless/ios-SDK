//
//  NumberWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
#if 1
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
#else
	NSString *dataType = [NSString stringWithUTF8String:[data objCType]];
    
	[DebLog log:_ON_WRITERS_LOG_ text:@"NumberWriter  ----  NSNumber->objCType: '%@', data = %@ [%@]", dataType, data, [self isBoolNumber:data]?@"BOOL":@"NUM"];
	
	if ([dataType compare:@"c"] == NSOrderedSame)
		[writer writeBoolean:[data boolValue]];
	else 
        if ([dataType compare:@"f"] == NSOrderedSame) 
            [writer writeDouble:[[NSString stringWithFormat:@"%g", [data floatValue]] doubleValue]];
        else 
            if ([dataType compare:@"d"] == NSOrderedSame)
                [writer writeDouble:[data doubleValue]];
            else
                [writer writeInteger:[data doubleValue]];
#endif
}

-(BOOL)isBoolNumber:(NSNumber *)num {
    CFTypeID boolID = CFBooleanGetTypeID(); // the type ID of CFBoolean
    CFTypeID numID = CFGetTypeID((__bridge CFTypeRef)(num)); // the type ID of num
    return numID == boolID;
}

@end
