//
//  ISharedObjectHandlerProvider.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IServiceHandlerProvider.h"

@protocol ISharedObjectHandlerProvider <IServiceHandlerProvider>
/**
 * Register an object that provides methods which handle calls without
 * a service name to a shared object.
 * 
 * @param handler
 * 			the handler object
 */
-(void)registerServiceHandler:(id)handler;

@end
