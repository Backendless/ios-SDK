//
//  NamedObject.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICacheableAdaptingType.h"

@interface NamedObject : NSObject <ICacheableAdaptingType> {
	NSString			*objectName;
	id <IAdaptingType>	typedObject;
    Class               mappedType;
}

+(id)objectType:(NSString *)name withObject:(id <IAdaptingType>)object;
-(Class)getMappedType;

@end
