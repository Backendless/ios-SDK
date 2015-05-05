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
    UNKNOWN_DATATYPE,
    INT_DATATYPE,
    STRING_DATATYPE,
    BOOLEAN_DATATYPE,
    DATETIME_DATATYPE,
    DOUBLE_DATATYPE,
    RELATION_DATATYPE,
    COLLECTION_DATATYPE,
    RELATION_LIST_DATATYPE,
    STRING_ID_DATATYPE,
    TEXT_DATATYPE
} ObjectDataType;

@interface AbstractProperty : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *required;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *selected;
@property (strong, nonatomic) id defaultValue;
-(BOOL)isRequired;
-(void)isRequired:(BOOL)required;
-(BOOL)isSelected;
-(void)isSelected:(BOOL)selected;
-(ObjectDataType)objectDataType;
-(void)objectDataType:(ObjectDataType)dataType;
@end
