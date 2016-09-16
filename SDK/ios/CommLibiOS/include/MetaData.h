//
//  MetaData.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 4/16/13.
//  Copyright (c) 2013 The Midnight Coders, Inc. All rights reserved.
//

#import "Notify.h"

#define SET_DATA_FRAME @"@setDataFrame"
#define SET_DATA_EVENT @"__setDataEvent"
#define ON_METADATA @"onMetaData"

@interface MetaData : Notify
@property (nonatomic, retain) NSString      *dataSet;
@property (nonatomic, retain) NSString      *eventName;
@property (nonatomic, retain) NSDictionary  *metadata;
@property (nonatomic, retain) id            object;

-(id)initWithMetadata:(NSDictionary *)metadata;
-(id)initWithObject:(id)object;
@end
