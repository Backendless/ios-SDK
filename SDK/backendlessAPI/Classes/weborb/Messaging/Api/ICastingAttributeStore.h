//
//  ICastingAttributeStore.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "IAttributeStore.h"

@protocol ICastingAttributeStore <IAttributeStore>
/**
 * Get Boolean attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(BOOL)getBoolAttribute:(NSString *)name;

/**
 * Get Byte attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(char)getByteAttribute:(NSString *)name;

/**
 * Get Double attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(double)getDoubleAttribute:(NSString *)name;

/**
 * Get Integer attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(int)getIntAttribute:(NSString *)name;

/**
 * Get boolean attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(long)getLongAttribute:(NSString *)name;

/**
 * Get Short attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(short)getShortAttribute:(NSString *)name;

/**
 * Get List attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(NSArray *)getListAttribute:(NSString *)name;

/**
 * Get Long attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(NSDictionary *)getMapAttribute:(NSString *)name;

/**
 * Get Set attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(NSSet *)getSetAttribute:(NSString *)name;

/**
 * Get String attribute by name
 * 
 * @param name
 *            Attribute name
 * @return		Attribute
 */
-(NSString *)getStringAttribute:(NSString *)name;

@end
