//
//  ObjectSerializer.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 26.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ObjectSerializer.h"
#import "DEBUG.h"
#import "MessageWriter.h"
#import "RTMPConstants.h"

#define LENGTH_ARRAY_MAP @"length"

@implementation ObjectSerializer

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ObjectSerializer"];
 	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(BOOL)writeObjectMap:(NSDictionary *)objectFields format:(IProtocolFormatter *)writer {
    
    if ([objectFields valueForKey:AS_ARRAY_MAP]) {
        
        [DebLog logN:@"ObjectSerializer -> writeObjectMap: AS_ARRAY_MAP"];
        
        int maxInt = -1;
        for (int i = 0; i < objectFields.count; i++) {
            if (![objectFields valueForKey:[NSString stringWithFormat:@"%d",i]])
                break;
            maxInt = i;
        }
        
        [writer beginWriteObjectMap:maxInt+1];
        
        NSArray *fields = [objectFields allKeys];
        for (NSString *fieldName in fields) {
            
            if ([fieldName isEqualToString:AS_ARRAY_MAP])
                continue;
            
            [writer writeFieldName:fieldName];
            [writer beginWriteFieldValue];
            [[MessageWriter sharedInstance] writeObject:[objectFields valueForKey:fieldName] format:writer];
            [writer endWriteFieldValue];
        }
        
        if (maxInt >= 0) {
            [writer writeFieldName:LENGTH_ARRAY_MAP];
            [[MessageWriter sharedInstance] writeObject:[NSNumber numberWithInt:maxInt+1] format:writer];
        }
        
        [writer endWriteObjectMap];
    
        return YES;
    }
    
    if ([objectFields valueForKey:AS_ARRAY_METADATA]) {
        
        [DebLog logN:@"ObjectSerializer -> writeObjectMap: AS_ARRAY_METADATA"];
        
        [writer beginWriteObjectMap:0];
        
        NSArray *fields = [objectFields allKeys];
        for (NSString *fieldName in fields) {
            
            if ([fieldName isEqualToString:AS_ARRAY_METADATA])
                continue;
            
            [writer writeFieldName:fieldName];
            [writer beginWriteFieldValue];
            [[MessageWriter sharedInstance] writeObject:[objectFields valueForKey:fieldName] format:writer];
            [writer endWriteFieldValue];
        }
        
        [writer endWriteObject];
        
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark IObjectSerializer Methods

-(void)writeObject:(NSString *)className fields:(NSDictionary *)objectFields format:(IProtocolFormatter *)writer {
    
    [DebLog logN:@"ObjectSerializer -> writeObject: className = %@", className];
    
    if ([self writeObjectMap:objectFields format:writer]) 
        return;

    if (className)
        [writer beginWriteNamedObject:className fields:(int)[objectFields count]];
    else 
        [writer beginWriteObject:(int)[objectFields count]];
    
    NSArray *fields = [objectFields allKeys];
    for (NSString *fieldName in fields) {
        [writer writeFieldName:fieldName];
        [writer beginWriteFieldValue];
        [[MessageWriter sharedInstance] writeObject:[objectFields valueForKey:fieldName] format:writer];
        [writer endWriteFieldValue];
    }
    
    if (className)
        [writer endWriteNamedObject];
    else 
        [writer endWriteObject];
}

@end
