//
//  AbstractProperty.m
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

#import "AbstractProperty.h"
#import "DEBUG.h"

static char *types[] = {"UNKNOWN", "INT" , "STRING", "BOOLEAN", "DATETIME", "DOUBLE", "RELATION", "COLLECTION", "RELATION_LIST", "STRING_ID", "TEXT"};

@implementation AbstractProperty

-(id)init {
	if (self = [super init]) {
        self.name = nil;
        self.required = nil;
        self.type = nil;
        self.selected = nil;
        self.defaultValue = nil;
    }
	return self;
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC AbstractProperty"];
    [_name release];
    [_required release];
    [_type release];
    [_selected release];
    [_defaultValue release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)isRequired {
    return _required && [_required boolValue];
}

-(void)isRequired:(BOOL)required {
    self.required = @(required);
}

-(BOOL)isSelected {
    return _selected && [_selected boolValue];
}

-(void)isSelected:(BOOL)selected {
    self.selected = @(selected);
}

-(ObjectDataType)objectDataType {
    if (_type) {
        if ([_type isEqualToString:@"$"])
            return DOUBLE_DATATYPE;
        for (int i = 0; i <= TEXT_DATATYPE; i++)
            if ([_type isEqualToString:[NSString stringWithUTF8String:types[i]]])
                return (ObjectDataType)i;
    }    
    return UNKNOWN_DATATYPE;
}

-(void)objectDataType:(ObjectDataType)dataType {
    self.type = [NSString stringWithUTF8String:types[(int)dataType]];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<AbstractProperty> name = %@, required = %@, type = %@, selected = %@, defaultValue = %@", _name, [self isRequired]?@"YES":@"NO", _type, [self isSelected]?@"YES":@"NO", _defaultValue];
}

@end
