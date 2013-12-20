//
//  AbstractProperty.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <Foundation/Foundation.h>

typedef enum {
//    OBJ_STRING,
//    OBJ_BOOLEAN,
//    OBJ_NUMBER,
//    OBJ_DATE,
//    OBJ_RELATION
    OBJ_UNKNOWN,
    OBJ_INT,
    OBJ_STRING,
    OBJ_BOOLEAN,
    OBJ_DATETIME,
    OBJ_DOUBLE,
    OBJ_RELATION,
    OBJ_COLLECTION,
    OBJ_RELATION_LIST,
    OBJ_STRING_ID,
    OBJ_TEXT
} ObjectDataType;

@interface AbstractProperty : NSObject

@property (strong, nonatomic) NSNumber *identity;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *required;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *selected;
@property (strong, nonatomic) id defaultValue;

-(BOOL)isIdentity;
-(BOOL)isRequired;
-(BOOL)isSelected;
-(ObjectDataType)objectDataType;

@end
