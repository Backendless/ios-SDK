//
//  AttributeStore.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AttributeStore.h"
#import "DEBUG.h"


@implementation AttributeStore

-(id)init {	
	if( (self=[super init]) ) {
		attributes = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(id)initWithAttributes:(NSDictionary *)values {
	if( (self=[super init]) ) {
		attributes = [[NSMutableDictionary alloc] init];
		[self setAttributes:values];
	}	
	return self;
}

-(id)initWithAttributeStore:(id <IAttributeStore>)values {
	if( (self=[super init]) ) {
		attributes = [[NSMutableDictionary alloc] init];
		[self setAttributeStore:values];
	}	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AttributeStore"];
	
	[attributes removeAllObjects];
    [attributes release];
		
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods


#pragma mark -
#pragma mark IAttributeStore Methods

-(NSArray *)getAttributeNames {
	
	return [attributes allKeys];
}

-(NSDictionary *)getAttributes {
	
	return attributes;
}

-(BOOL)setAttribute:(NSString *)name object:(id)value {
	
	if (!name)
		return NO;
	
	if (!value)
		value = [NSNull null];
	
	[attributes setValue:value forKey:name];

	return YES;
}

-(void)setAttributes:(NSDictionary *)values {
	NSArray *names = [values allKeys]; 
	for (NSString *name in names) 
		[self setAttribute:name object:[values valueForKey:name]];
}

-(void)setAttributeStore:(id <IAttributeStore>)values {
	[self setAttributes:[values getAttributes]];
}

-(id)getAttribute:(NSString *)name {
	return (name) ? [attributes valueForKey:name] : nil;
}

-(id)getAttribute:(NSString *)name object:(id)defaultValue {
	
	if (![self hasAttribute:name])
		[self setAttribute:name object:defaultValue];

	return [self getAttribute:name];
}

-(BOOL)hasAttribute:(NSString *)name {
	
	if (!name)
		return NO;
	
	return ([self getAttribute:name] != nil);
}

-(BOOL)removeAttribute:(NSString *)name {
	
	if (!name)
		return NO;
	
	[attributes removeObjectForKey:name];
	
	return YES;
}

-(void)removeAttributes {
	[attributes removeAllObjects];
}


#pragma mark -
#pragma mark ICastingAttributeStore Methods

-(BOOL)getBoolAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj boolValue] : NO;
}

-(char)getByteAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj charValue] : 0;
}

-(double)getDoubleAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj doubleValue] : 0.0f;
}

-(int)getIntAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj intValue] : 0;
}

-(long)getLongAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj longValue] : 0;
}

-(short)getShortAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isMemberOfClass:[NSNumber class]]) ? [(NSNumber *)obj shortValue] : 0;
}

-(NSArray *)getListAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isKindOfClass:[NSArray class]]) ? (NSArray *)obj : nil;
}

-(NSDictionary *)getMapAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isKindOfClass:[NSDictionary class]]) ? (NSDictionary *)obj : nil;
}

-(NSSet *)getSetAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isKindOfClass:[NSSet class]]) ? (NSSet *)obj : nil;
}

-(NSString *)getStringAttribute:(NSString *)name {
	id obj = [self getAttribute:name];
	return (obj && [obj isKindOfClass:[NSString class]]) ? (NSString *)obj : nil;
}

@end
