//
//  PendingCall.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPendingServiceCall.h"
#import "Call.h"

@interface PendingCall : Call <IPendingServiceCall> {
	id				_result;
	NSMutableArray  *callbacks;
}
@end
