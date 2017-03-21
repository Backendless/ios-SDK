//
//  SharedObjectEvent.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 20.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISharedObjectEvent.h"
#import "SharedObjectEventType.h"

@interface SharedObjectEvent : NSObject <ISharedObjectEvent> {
	SharedObjectEventType	type;
	NSString				*key;
	id						value;
}

-(id)initWithType:(SharedObjectEventType)_type withKey:(NSString *)_key andValue:(id)_value;
@end
