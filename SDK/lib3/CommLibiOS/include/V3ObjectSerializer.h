//
//  V3ObjectSerializer.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IObjectSerializer.h"
#import "IProtocolFormatter.h"


@interface V3ObjectSerializer : NSObject <IObjectSerializer> {
       
}
-(void)writeObject:(NSString *)className fields:(NSDictionary *)objectFields format:(IProtocolFormatter *)writer;
@end
