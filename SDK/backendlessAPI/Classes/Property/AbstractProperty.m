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

#import "AbstractProperty.h"
#import "DEBUG.h"

static char *types[] = {"UNKNOWN", "INT" , "STRING", "BOOLEAN", "DATETIME", "DOUBLE", "RELATION", "COLLECTION", "RELATION_LIST", "STRING_ID", "TEXT"};

//{"STRING", "BOOLEAN", "NUMBER", "DATE", "RELATION"};

@implementation AbstractProperty

-(id)init {
	if ( (self=[super init]) ) {
        self.name = nil;
        self.identity = nil;
        self.required = nil;
        self.type = nil;
        self.selected = nil;
        self.defaultValue = nil;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AbstractProperty"];
    
    [_identity release];
    [_name release];
    [_required release];
    [_type release];
    [_selected release];
    [_defaultValue release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)isIdentity {
    return (_identity) && [_identity boolValue];
}

-(BOOL)isRequired {
    return (_required) && [_required boolValue];
}

-(BOOL)isSelected {
    return (_selected) && [_selected boolValue];
}

-(ObjectDataType)objectDataType {
    
    if (_type) {
    
        if ([_type isEqualToString:@"$"])
            return OBJ_DOUBLE;
    
        for (int i = 0; i <= OBJ_RELATION; i++)
            if ([_type isEqualToString:[NSString stringWithUTF8String:types[i]]])
                return i;
    }
    
    return OBJ_STRING;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<AbstractProperty> identity = %@, name = %@, required = %@, type = %@, selected = %@, defaultValue = %@", [self isIdentity]?@"YES":@"NO", _name, [self isRequired]?@"YES":@"NO", _type, [self isSelected]?@"YES":@"NO",_defaultValue];
}

@end
