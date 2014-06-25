//
//  Events.h
//  backendlessAPI
//
//  Created by Yury Yaschenko on 6/25/14.
//  Copyright (c) 2014 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol IResponder;
@class Fault;
@interface Events : NSObject
-(NSDictionary *)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs fault:(Fault **)fault;
-(void)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs responder:(id <IResponder>)responder;
-(void)dispatchEventName:(NSString *)name args:(NSDictionary *)eventArgs response:(void(^)(NSDictionary *)data)responseBlock error:(void(^)(Fault *fault))errorBlock
@end
