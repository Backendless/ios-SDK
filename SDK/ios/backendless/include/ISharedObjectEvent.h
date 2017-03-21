//
//  ISharedObjectEvent.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
