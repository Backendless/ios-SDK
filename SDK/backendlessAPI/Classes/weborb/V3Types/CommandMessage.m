//
//  CommandMessage.m
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 3/22/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "CommandMessage.h"

@implementation CommandMessage
@synthesize operation;

-(id)init {
    
    if ( (self = [super init]) ) {
        operation = nil;
    }
    
    return self;
}
 
-(id)initWithOperation:(NSString *)_operation {
    
    if ( (self = [super init]) ) {
        operation = [NSString stringWithString:_operation];
    }
    
    return self;
}

+(id)command:(NSString *)_operation {
    return [[[CommandMessage alloc] initWithOperation:_operation] autorelease];
}

#pragma mark -
#pragma mark Public Methods

@end
