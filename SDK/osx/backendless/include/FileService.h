//
//  FileService.h
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
#import "FilePermission.h"

@class BackendlessFile, Fault;
@protocol IResponder;

@interface FileService : NSObject

@property (strong, nonatomic, readonly) FilePermission *permissions;

// sync methods with fault return (as exception)
-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content;
-(id)remove:(NSString *)fileURL;
-(id)removeDirectory:(NSString *)path;
-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content;
-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite;
-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content;
-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite;

// sync methods with fault option
-(BackendlessFile *)upload:(NSString *)path content:(NSData *)content error:(Fault **)fault;
-(BOOL)remove:(NSString *)fileURL error:(Fault **)fault;
-(BOOL)removeDirectory:(NSString *)path error:(Fault **)fault;
-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content error:(Fault **)fault;
-(BackendlessFile *)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault;
-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content error:(Fault **)fault;
-(BackendlessFile *)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite error:(Fault **)fault;

// async methods with responder
-(void)upload:(NSString *)path content:(NSData *)content responder:(id <IResponder>)responder;
-(void)remove:(NSString *)fileURL responder:(id <IResponder>)responder;
-(void)removeDirectory:(NSString *)path responder:(id <IResponder>)responder;
-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content responder:(id <IResponder>)responder;
-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder;
-(void)saveFile:(NSString *)filePathName content:(NSData *)content responder:(id <IResponder>)responder;
-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite responder:(id <IResponder>)responder;

// async methods with block-based callbacks
-(void)upload:(NSString *)path content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)remove:(NSString *)fileURL response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)removeDirectory:(NSString *)path response:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)saveFile:(NSString *)path fileName:(NSString *)fileName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)saveFile:(NSString *)filePathName content:(NSData *)content response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock;
-(void)saveFile:(NSString *)filePathName content:(NSData *)content overwriteIfExist:(BOOL)overwrite response:(void(^)(BackendlessFile *))responseBlock error:(void(^)(Fault *))errorBlock;

@end
