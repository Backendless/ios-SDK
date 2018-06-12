//
//  Body.h
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


@interface Body : NSObject {
    NSString    *serviceUri;
    NSString    *responseUri;
    id          dataObject;
    id          responseDataObject;
}
@property (nonatomic, assign) NSString *serviceUri;
@property (nonatomic, assign) NSString *responseUri;
@property (nonatomic, assign) id dataObject;
@property (nonatomic, assign) id responseDataObject;

-(id)initWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length;
+(id)bodyWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length;
@end
