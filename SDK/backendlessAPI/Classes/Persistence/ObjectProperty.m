//
//  ObjectProperty.m
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

#import "ObjectProperty.h"
#import "DEBUG.h"

@implementation ObjectProperty

-(id)init {
    if (self = [super init]) {
        self.relatedTable = nil;
        self.customRegex = nil;
        self.primaryKey = nil;
        self.autoLoad = nil;
    }
    return self;
}

-(void)dealloc {
	[DebLog logN:@"DEALLOC ObjectProperty"];
    [_relatedTable release];
    [_customRegex release];
    [_primaryKey release];
    [_autoLoad release];	
	[super dealloc];
}

+(id)objectProperty:(NSString *)name {
    ObjectProperty *instance = [ObjectProperty new];
    instance.name = name;
    return instance;
}

+(id)objectProperty:(NSString *)name dataType:(ObjectDataType)type required:(BOOL)required {
    ObjectProperty *instance = [ObjectProperty new];
    instance.name = name;
    instance.required = @(required);
    [instance objectDataType:type];
    return instance;
}

-(BOOL)isPrimaryKey {
    return _primaryKey && [_primaryKey boolValue];
}

-(void)isPrimaryKey:(BOOL)primaryKey {
    self.primaryKey = @(primaryKey);
}

-(BOOL)isAutoLoad {
    return _autoLoad && [_autoLoad boolValue];
}

-(void)isAutoLoad:(BOOL)autoLoad {
    self.autoLoad = @(autoLoad);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@\n<ObjectProperty> relatedTable: %@, customRegex: %@, primaryKey: %@, autoLoad: %@", [super description], _relatedTable, _customRegex, [self isPrimaryKey]?@"YES":@"NO", [self isAutoLoad]?@"YES":@"NO"];
}

@end
