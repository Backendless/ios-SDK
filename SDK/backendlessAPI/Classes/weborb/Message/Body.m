//
//  Body.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Body.h"
#import "DEBUG.h"
#import "IAdaptingType.h"
#import "ArrayType.h"


@implementation Body
@synthesize serviceUri, responseUri, dataObject, responseDataObject;

-(id)init {	
	if ( (self=[super init]) ) {
        serviceUri = nil;
        responseUri = nil;
        dataObject = nil; 
        responseDataObject = nil;
	}
	
	return self;
}

-(id)initWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length {
	if ( (self=[super init]) ) {
        
        serviceUri = serviceURI;
        responseUri = responseURI;
        
        [DebLog logN:@"Body -> initWithObject: (0)"];
               
        if ([dataObj conformsToProtocol:@protocol(IAdaptingType)]) {
            
            if ([dataObj isMemberOfClass:[ArrayType class]]) {
                dataObject = [(ArrayType *)dataObj getArray];
                
                [DebLog logN:@"Body -> initWithObject: (1)"];
            }
            else {
                // TODO: is it right?
                dataObject = [NSMutableArray array];
                [dataObject addObject:dataObj];
                
                [DebLog logN:@"Body -> initWithObject: (2)"];
            }
        }
        else {
            dataObject = dataObj;
            
            [DebLog logN:@"Body -> initWithObject: (3)"];
        }
	}
	
	return self;
}

+(id)bodyWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length {	
	return [[[Body alloc] initWithObject:dataObj serviceURI:serviceURI responseURI:responseURI length:length] autorelease];
}

@end
