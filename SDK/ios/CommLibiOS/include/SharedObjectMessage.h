//
//  SharedObjectMessage.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseEvent.h"
#import "ISharedObjectMessage.h"

@interface SharedObjectMessage : BaseEvent <ISharedObjectMessage> {
	NSString		*name;
	NSMutableArray	*events;
	int				version;
	BOOL			persistent;
}

-(id)initWithName:(NSString *)_name version:(int)_version persistent:(BOOL)_persistent;	
-(id)initWithSource:(id <IEventListener>)_source name:(NSString *)_name version:(int)_version persistent:(BOOL)_persistent;	

-(void)setVersion:(int)_version;
-(void)setName:(NSString *)_name;
-(void)setIsPersistent:(BOOL)_persistent;
-(void)addEvents:(NSArray *)listEvents;
-(EventType)getType;
-(id)getObject;
@end
