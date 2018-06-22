//
//  MetaData.h
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


#import "NotifyEvent.h"

#define SET_DATA_FRAME @"@setDataFrame"
#define SET_DATA_EVENT @"__setDataEvent"
#define ON_METADATA @"onMetaData"

@interface MetaData : NotifyEvent
@property (nonatomic, retain) NSString      *dataSet;
@property (nonatomic, retain) NSString      *eventName;
@property (nonatomic, retain) NSDictionary  *metadata;
@property (nonatomic, retain) id            object;

-(id)initWithMetadata:(NSDictionary *)metadata;
-(id)initWithObject:(id)object;
@end
