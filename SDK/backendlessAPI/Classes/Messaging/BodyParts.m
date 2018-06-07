//
//  BodyParts.m
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

#import "BodyParts.h"

@implementation BodyParts

-(id)initWithText:(NSString *)text html:(NSString *)html {
    if (self = [super init]) {
        self.textMessage = text;
        self.htmlMessage = html;
    }    
    return self;
}

-(void)dealloc {
    [_textMessage release];
    [_htmlMessage release];
    [super dealloc];
}

+(id)bodyText:(NSString *)text html:(NSString *)html {
    return [[[BodyParts alloc] initWithText:text html:html] autorelease];
}

-(BOOL)isBody {
    return _textMessage || _htmlMessage;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<BodyParts> textMessage: %@, \nhtmlMessage: %@", _textMessage, _htmlMessage];
}

@end
