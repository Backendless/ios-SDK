//
//  BodyParts.m
//  backendlessAPI
//
//  Created by Yury Yaschenko on 10/14/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "BodyParts.h"

@implementation BodyParts
@synthesize textMessage, htmlMessage;
-(void)dealloc
{
    [textMessage release];
    [htmlMessage release];
    [super dealloc];
}
@end
