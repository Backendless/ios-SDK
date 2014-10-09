//
//  MediaPlaybackOptions.h
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

#if TARGET_OS_IPHONE
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaPlaybackOptions : NSObject

@property BOOL isLive;
@property BOOL isRealTime;
@property uint clientBufferMs;
@property UIImageOrientation orientation;
@property (assign, nonatomic) UIImageView *previewPanel;

+(id)liveStream:(UIImageView *)view;
+(id)recordStream:(UIImageView *)view;
+(id)options:(BOOL)isLive orientation:(UIImageOrientation)orientation view:(UIImageView *)view;
-(NSString *)getServerURL;
@end
#else
@interface MediaPlaybackOptions : NSObject
@end
#endif
