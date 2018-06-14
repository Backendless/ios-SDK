//
//  ICastingAttributeStore.h
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
