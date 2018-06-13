//
//  MemoryTicker.h
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

@interface MemoryTicker : NSObject {
    
    id      responder;
    SEL     selGetMemory;
    BOOL    inBytes;
    BOOL    asNumber;
    float   tick;
}
@property BOOL inBytes;
@property BOOL asNumber;

-(id)initWithResponder:(id)_responder andMethod:(SEL)method;

-(void)applicationUsedMemoryReport;

+(double)getAvailableMemoryInBytes;
+(double)getAvailableMemoryInKiloBytes;
+(NSString *)showAvailableMemoryInBytes;
+(NSString *)showAvailableMemoryInKiloBytes;
-(double)getAvailableMemory;
-(NSString *)showAvailableMemory;
-(void)tickerStart:(float)aTick;
-(void)tickerStart;
-(void)tickerStop;
@end
