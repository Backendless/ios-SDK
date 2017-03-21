//
//  IPendingServiceCall.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IServiceCall.h"
#import "IPendingServiceCallback.h"

@protocol IPendingServiceCall <IServiceCall>
-(void)registerCallback:(id <IPendingServiceCallback>)callback;
-(void)unregisterCallback:(id <IPendingServiceCallback>)callback;
-(NSArray *)getCallbacks;
-(id)getResult;
-(void)setResult:(id)result;
@end
