//
//  IPersistable.h
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

@protocol IPersistenceStore;
@class FlashorbBinaryWriter, FlashorbBinaryReader;

@protocol IPersistable <NSObject>

/**
 * Returns <code>true</code> if the object is persistent,
 * <code>false</code> otherwise.
 * 
 * @return <code>true</code> if object is persistent, <code>false</code> otherwise
 */
-(BOOL)isPersistent;

/**
 * Set the persistent flag of the object.
 * 
 * @param persistent
 * 		<code>true</code> if object is persistent, <code>false</code> otherwise
 */
-(void)setPersistent:(BOOL)persistent;

/**
 * Returns the name of the persistent object.
 * 
 * @return Object name
 */
-(NSString *)getName;

/**
 * Set the name of the persistent object.
 * 
 * @param name
 * 		New object name
 */
-(void)setName:(NSString *)name;

/**
 * Returns the type of the persistent object.
 * 
 * @return Object type
 */
-(NSString *)getType;

/**
 * Returns the path of the persistent object.
 * 
 * @return Persisted object path
 */
-(NSString *)getPath;

/**
 * Set the path of the persistent object.
 * 
 * @param path
 * 		New persisted object path
 */
-(void)setPath:(NSString *)path;

/**
 * Returns the timestamp when the object was last modified.
 * 
 * @return      Last modification date in milliseconds
 */
-(long)getLastModified;

/**
 * Returns the persistence store this object is stored in
 * 
 * @return      This object's persistence store
 */
-(id <IPersistenceStore>)getStore;

/**
 * Store a reference to the persistence store in the object.
 * 
 * @param store
 * 		Store the object is saved in
 */
-(void)setStore:(id <IPersistenceStore>)store;

/**
 * Write the object to the passed output stream.
 * 
 * @param output
 * 		Output stream to write to
 * @throws java.io.IOException     Any I/O exception
 */
-(void)serialize:(FlashorbBinaryWriter *)output;

/**
 * Load the object from the passed input stream.
 * 
 * @param input
 * 		Input stream to load from
 * @throws java.io.IOException      Any I/O exception
 */
-(void)deserialize:(FlashorbBinaryReader *)input;

@end
