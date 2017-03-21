//
//  ISharedObjectBase.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ISharedObjectHandlerProvider.h"
#import "ICastingAttributeStore.h"
#import "IEventListener.h"

@protocol ISharedObjectListener;

@protocol ISharedObjectBase <ISharedObjectHandlerProvider, ICastingAttributeStore>

/**
 * Returns the version of the shared object. The version is incremented
 * automatically on each modification.
 * 
 * @return the version of the shared object
 */
-(int)getVersion;

/**
 * Check if the object has been created as persistent shared object by the
 * client.
 * 
 * @return true if the shared object is persistent, false otherwise
 */
-(BOOL)isPersistentObject;

/**
 * Return a map containing all attributes of the shared object. <br />
 * NOTE: The returned map will be read-only.
 * 
 * @return a map containing all attributes of the shared object
 */
-(NSDictionary *)getData;

/**
 * Send a message to a handler of the shared object.
 * 
 * @param handler
 *            the name of the handler to call
 * @param arguments
 *            a list of objects that should be passed as arguments to the
 *            handler
 */
-(void)sendMessage:(NSString *)handler arguments:(NSArray *)arguments;

/**
 * Start performing multiple updates to the shared object from serverside
 * code.
 */
-(void)beginUpdate;

/**
 * Start performing multiple updates to the shared object from a connected
 * client.
 * @param source      Update events listener
 */
-(void)beginUpdate:(id <IEventListener>)source;

/**
 * The multiple updates are complete, notify clients about all changes at
 * once.
 */
-(void)endUpdate;

/**
 * Register object that will be notified about update events.
 * 
 * @param listener
 * 				the object to notify
 */
-(void)addSharedObjectListener:(id <ISharedObjectListener>)listener;

/**
 * Checks if shared object listener is already registered
 */ 
-(BOOL)hasSharedObjectListener:(id <ISharedObjectListener>)listener;

/**
 * Unregister object to not longer receive update events.
 *  
 * @param listener
 * 				the object to unregister
 */
-(void)removeSharedObjectListener:(id <ISharedObjectListener>)listener;

/** 
 * Returns a list of shared object listeners
 */ 
-(NSArray *)getSharedObjectListeners;
/**
 * Locks the shared object instance. Prevents any changes to this object by
 * clients until the SharedObject.unlock() method is called.
 */
-(void)lockSO;

/**
 * Unlocks a shared object instance that was locked with
 * SharedObject.lock().
 */
-(void)unlockSO;

/**
 * Returns the locked state of this SharedObject.
 * 
 * @return true if in a locked state; false otherwise
 */
-(BOOL)isLocked;

/**
 * Deletes all the attributes and sends a clear event to all listeners. The
 * persistent data object is also removed from a persistent shared object.
 * 
 * @return true if successful; false otherwise
 */
-(BOOL)clear;

/**
 * Detaches a reference from this shared object, this will destroy the
 * reference immediately. This is useful when you don't want to proxy a
 * shared object any longer.
 */
-(void)close;

-(int)getConnectionCount;

@end
