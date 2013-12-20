//
//  PublishMessageInfo.h
//  backendlessAPI
//
//  Created by Vyacheslav Vdovichenko on 10/2/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublishMessageInfo : NSObject {
    
    NSString *message;
    NSString *publisherId;
    NSString *subtopic;
    NSNumber *pushBroadcast;
    NSArray  *pushSinglecast;
    NSMutableDictionary *headers;
}
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *publisherId;
@property (strong, nonatomic) NSString *subtopic;
@property (strong, nonatomic) NSNumber *pushBroadcast;
@property (strong, nonatomic) NSArray  *pushSinglecast;
@property (strong, nonatomic) NSMutableDictionary *headers;

-(id)initWithMessage:(NSString *)_message;
-(void)addHeaders:(NSDictionary *)_headers;
@end
