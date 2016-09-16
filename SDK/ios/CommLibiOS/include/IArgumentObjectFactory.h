//
//  IArgumentObjectFactory.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/19/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"

@protocol IArgumentObjectFactory <NSObject>
-(id)createObject:(id <IAdaptingType>)argument;
@end
