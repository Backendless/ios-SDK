//
//  Request.m
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

#import "Request.h"
#import "DEBUG.h"
#import "Body.h"

@implementation Request
@synthesize headers, bodyParts;

-(id)init {	
	if ( (self=[super init]) ) {
        version = 0.0f;
        headers = nil;
        bodyParts = nil;
        responseBodies = [[NSMutableArray alloc] init];
        currentBody = 0;
        formatter = nil;
	}
	
	return self;
}

-(id)initForVersion:(float)ver headers:(NSArray *)headerAr bodies:(NSMutableArray *)bodyAr {	
	if ( (self=[super init]) ) {
        version = ver;
        headers = headerAr;
        bodyParts = bodyAr;
        responseBodies = [[NSMutableArray alloc] init];
        currentBody = 0;
        formatter = nil;
	}
	
	return self;
}

+(id)request:(float)ver headers:(NSArray *)headerAr bodies:(NSMutableArray *)bodyAr {
    return [[[Request alloc] initForVersion:ver headers:headerAr bodies:bodyAr] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC Request"];
	
	[responseBodies removeAllObjects];
	[responseBodies release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark getters & setters

-(int)currentBody {
    return currentBody;
}

-(void)setCurrentBody:(int)value {
    if (value < bodyParts.count)
        currentBody = value;
}

#pragma mark -
#pragma mark Public Methods

-(float)getVersion {
    return version;
}

-(int)getBodyCount {
    return (int)bodyParts.count;
}

-(NSString *)getRequestURI {
    Body *body = [bodyParts objectAtIndex:currentBody];
    return body.serviceUri;    
}

-(id)getRequestBodyData {
    Body *body = [bodyParts objectAtIndex:currentBody];
    return body.dataObject;
}

-(void)setRequestBodyData:(id)obj {
    Body *body = [bodyParts objectAtIndex:currentBody];
    body.dataObject = obj;    
}

-(void)setResponseBodyData:(id)obj {
    Body *body = [bodyParts objectAtIndex:currentBody];
    body.responseDataObject = obj;
    [responseBodies addObject:body];
}

-(void)setResponseURI:(NSString *)responseURI {
    Body *body = [bodyParts objectAtIndex:currentBody];
    body.serviceUri = [NSString string];
    body.responseUri = responseURI;
}

-(MHeader *)getHeader:(NSString *)headerName {
    for (MHeader *header in headers) {
        if ([header.headerName isEqualToString:headerName])
            return header;
    }
    
    return nil;
}

-(NSArray *)getResponseHeaders {
    return [NSArray array]; // TODO: need to implement
}

-(NSArray *)getResponseBodies {
    return [NSArray arrayWithArray:responseBodies];
}

-(BOOL)isV3Request {
    return [[self getRequestBodyData] isMemberOfClass:[NSArray class]];
}

-(IProtocolFormatter *)getFormatter {
    return formatter;
}

-(void)setFormatter:(IProtocolFormatter *)form {
    formatter = form;
}

@end
