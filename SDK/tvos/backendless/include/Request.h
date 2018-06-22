//
//  Request.h
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
