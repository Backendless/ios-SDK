//
//  IServiceHandlerProvider.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@protocol IServiceHandlerProvider <NSObject>
@optional

/**
 * Register an object that provides methods which can be called from a
 * client.
 * 
 * <p>
 * Example:<br>
 * If you registered a handler with the name "<code>one.two</code>" that
 * provides a method "<code>callMe</code>", you can call a method
 * "<code>one.two.callMe</code>" from the client.</p>
 * 
 * @param name
 * 			the name of the handler
 * @param handler
 * 			the handler object
 */
-(void)registerServiceHandler:(NSString *)name handler:(id)handler;

/**
 * Unregister service handler.
 * 
 * @param name
 * 			the name of the handler
 */
-(void)unregisterServiceHandler:(NSString *)name;

/**
 * Return a previously registered service handler.
 * 
 * @param name
 * 			the name of the handler to return
 * @return the previously registered handler
 */
-(id)getServiceHandler:(NSString *)name;

/**
 * Get list of registered service handler names.
 * 
 * @return the names of the registered handlers
 */
-(NSArray *)getServiceHandlerNames;


@end
