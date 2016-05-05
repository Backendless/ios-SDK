//
//  BackendlessFile.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
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

@class Fault;
@protocol IResponder;

@interface BackendlessFile : NSObject

@property (strong, nonatomic) NSString *fileURL;

+(id)file:(NSString *)url;

// sync
-(void)remove;
-(void)remove:(Fault **)fault;
// async
-(void)removeWithResponder:(id <IResponder>)responder;
-(void)remove:(void(^)(id))responseBlock error:(void(^)(id))errorBlock;
@end
