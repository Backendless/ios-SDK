//
//  Request.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProtocolFormatter.h"
#import "MHeader.h"

@interface Request : NSObject {
    float           version;
    NSArray         *headers;
    NSMutableArray  *bodyParts;
    NSMutableArray  *responseBodies;
    int             currentBody;
    IProtocolFormatter *formatter;
}
@property (nonatomic, assign) NSArray *headers;
@property (nonatomic, assign) NSMutableArray *bodyParts;
@property (getter=currentBody, setter=setCurrentBody:) int currentBody;

-(id)initForVersion:(float)ver headers:(NSArray *)headerAr bodies:(NSMutableArray *)bodyAr;
+(id)request:(float)ver headers:(NSArray *)headerAr bodies:(NSMutableArray *)bodyAr;
-(float)getVersion;
-(int)getBodyCount;
-(NSString *)getRequestURI;
-(id)getRequestBodyData;
-(void)setRequestBodyData:(id)obj;
-(void)setResponseBodyData:(id)obj;
-(void)setResponseURI:(NSString *)responseURI;
-(MHeader *)getHeader:(NSString *)headerName;
-(NSArray *)getResponseHeaders;
-(NSArray *)getResponseBodies;
-(BOOL)isV3Request;
-(IProtocolFormatter *)getFormatter;
-(void)setFormatter:(IProtocolFormatter *)form;
@end
