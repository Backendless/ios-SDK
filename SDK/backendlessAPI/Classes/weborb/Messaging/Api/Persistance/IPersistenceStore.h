//
//  IPersistenceStore.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@protocol IPersistable;

@protocol IPersistenceStore <NSObject>

/**
 * Persist given object.
 *  
 * @param obj
 * 		Object to store
 * @return     <code>true</code> on success, <code>false</code> otherwise
 */
-(BOOL)save:(id <IPersistable>)obj;

/**
 * Load a persistent object with the given name.  The object must provide
 * either a constructor that takes an input stream as only parameter or an
 * empty constructor so it can be loaded from the persistence store.
 * 
 * @param name
 * 		the name of the object to load
 * @return The loaded object or <code>null</code> if no such object was
 *         found
 */
-(id <IPersistable>)load:(NSString *)name;

/**
 * Load state of an already instantiated persistent object.
 * 
 * @param obj
 * 		the object to initializ
 * @return true if the object was initialized, false otherwise
 */
-(BOOL)loadObj:(id <IPersistable>)obj;

/**
 * Delete the passed persistent object.
 *  
 * @param obj
 * 		the object to delete
 * @return        <code>true</code> if object was persisted and thus can be removed, <code>false</code> otherwise
 */
-(BOOL)removeObj:(id <IPersistable>)obj;

/**
 * Delete the persistent object with the given name.
 *  
 * @param name
 * 		the name of the object to delete
 * @return        <code>true</code> if object was persisted and thus can be removed, <code>false</code> otherwise
 */
-(BOOL)remove:(NSString *)name;

/**
 * Return iterator over the names of all already loaded objects in the
 * storage.
 * 
 * @return Iterator over all object names
 */
-(NSArray *)getObjectNames;

/**
 * Return iterator over the already loaded objects in the storage.
 * 
 * @return Iterator over all objects
 */
-(NSArray *)getObjects;


@end
