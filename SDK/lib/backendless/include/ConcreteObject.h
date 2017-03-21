//
//  ConcreteObject.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/7/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"


@interface ConcreteObject : NSObject <IAdaptingType> {
	id theObj;
    
}
+(id)objectType:(id)object;
@end
