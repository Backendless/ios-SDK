//
//  Notify.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 06.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IServiceCall.h"
#import "BaseEvent.h"
#import "BinaryStream.h"

@interface NotifyEvent : BaseEvent {
	id <IServiceCall>	call;
	BinaryStream		*data;
	int					invokeId;
	NSDictionary		*connectionParams;
}
@property (nonatomic, assign, readwrite) id <IServiceCall> call;
@property (nonatomic, assign, readwrite) BinaryStream *data;
@property (readwrite) int invokeId;
@property (nonatomic, assign, readwrite) NSDictionary *connectionParams;

-(id)initWithStream:(BinaryStream *)stream;
-(id)initWithCall:(id <IServiceCall>)_call;	

-(BOOL)equals:(id)event;
-(NSString *)toString;
-(NotifyEvent *)duplicate;

@end
