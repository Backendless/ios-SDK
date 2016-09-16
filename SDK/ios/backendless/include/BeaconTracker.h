//
//  BeaconTracker.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2015 BACKENDLESS.COM. All Rights Reserved.
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

@protocol IResponder, IPresenceListener;

@interface BeaconTracker : NSObject
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(BeaconTracker *)sharedInstance;
-(void)startMonitoring:(BOOL)runDiscovery frequency:(int)frequency listener:(id<IPresenceListener>)listener distanceChange:(double)distanceChange responder:(id<IResponder>)responder;
-(void)stopMonitoring;
#endif
@end
