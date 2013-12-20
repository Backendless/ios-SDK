//
//  ViewController.h
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

#import <UIKit/UIKit.h>
#import "Backendless.h"

@interface ViewController : UIViewController

@property (assign, nonatomic) IBOutlet UIButton *btnStopMedia;
@property (assign, nonatomic) IBOutlet UIButton *btnSwapCamera;
@property (assign, nonatomic) IBOutlet UIView *preview;
@property (assign, nonatomic) IBOutlet UIImageView *playbackView;

// userService
-(IBAction)registerControl:(id)sender;
-(IBAction)updateControl:(id)sender;
-(IBAction)loginControl:(id)sender;
-(IBAction)logoutControl:(id)sender;
-(IBAction)restorePasswordControl:(id)sender;
-(IBAction)describeUserClassControl:(id)sender;
-(IBAction)assingRole:(id)sender;
-(IBAction)unssingRole:(id)sender;
// persistenceService
-(IBAction)entitySaveControl:(id)sender;
-(IBAction)entityUpdateControl:(id)sender;
-(IBAction)dictSaveControl:(id)sender;
-(IBAction)findControl:(id)sender;

// geoSevice
-(IBAction)addControl:(id)sender;

// messagingService
-(IBAction)messagingControl:(id)sender;

// mediaService
-(IBAction)publishControl:(id)sender;
-(IBAction)playbackControl:(id)sender;
-(IBAction)stopMediaControl:(id)sender;
-(IBAction)switchCamerasControl:(id)sender;

@end
