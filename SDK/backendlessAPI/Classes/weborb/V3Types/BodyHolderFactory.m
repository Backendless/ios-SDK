//
//  BodyHolderFactory.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/19/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BodyHolderFactory.h"
#import "DEBUG.h"
#import "IAdaptingType.h"
#import "BodyHolder.h"
#import "ITypeReader.h"


@implementation BodyHolderFactory

+(id)factory {
    return [[[BodyHolderFactory alloc] init] autorelease];
}

#pragma mark -
#pragma mark IArgumentObjectFactory Methods

-(id)createObject:(id <IAdaptingType>)argument {
    
    [DebLog log:_ON_READERS_LOG_ text:@"BodyHolderFactory -> createObject: argument = %@", argument];
    
    BodyHolder *bodyObj = [[[BodyHolder alloc] init] autorelease];
    bodyObj.body = [argument defaultAdapt];
    
    [DebLog log:_ON_READERS_LOG_ text:@"BodyHolderFactory -> createObject: %@", bodyObj];
    
    return bodyObj;
}

@end
