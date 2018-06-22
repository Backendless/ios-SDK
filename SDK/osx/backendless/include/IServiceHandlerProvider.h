//
//  IServiceHandlerProvider.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

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
