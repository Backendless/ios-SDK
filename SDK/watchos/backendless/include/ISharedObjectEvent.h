//
//  ISharedObjectEvent.h
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

#import "SharedObjectEventType.h"

@protocol ISharedObjectEvent
/**
 * Returns the type of the event.
 *
 * @return the type of the event.
 */
-(SharedObjectEventType)getType;

/**
 * Returns the key of the event.
 * <p/>
 * Depending on the type this contains:
 * <ul>
 * <li>the attribute name to set for SET_ATTRIBUTE</li>
 * <li>the attribute name to delete for DELETE_ATTRIBUTE</li>
 * <li>the handler name to call for SEND_MESSAGE</li>
 * </ul>
 * In all other cases the key is <code>null</code>.
 *
 * @return the key of the event
 */
-(NSString *)getKey;

/**
 * Returns the value of the event.
 * <p/>
 * Depending on the type this contains:
 * <ul>
 * <li>the attribute value to set for SET_ATTRIBUTE</li>
 * <li>a list of parameters to pass to the handler for SEND_MESSAGE</li>
 * </ul>
 * In all other cases the value is <code>null</code>.
 *
 * @return the value of the event
 */
-(id)getValue;


@end
