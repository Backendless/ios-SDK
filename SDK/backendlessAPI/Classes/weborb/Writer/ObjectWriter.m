//
//  ObjectWriter.m
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


#import "ObjectWriter.h"
#import "DEBUG.h"
#import "Types.h"
#import "IProtocolFormatter.h"
#import "IObjectSerializer.h"
#import "V3Message.h"
#import "MessageWriter.h"


@implementation ObjectWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
    return [[ObjectWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)writer {
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"ObjectWriter -> write:%@ format:%@", obj, writer];
    
    if (!obj || !writer)
        return;
    
    // serialization preprocessor
    if ([obj isKindOfClass:[V3Message class]]) {
        V3Message *v3 = (V3Message *)obj;
        v3.body.body = [v3.body.body onAMFSerialize];
    }
    else {
        obj = [obj onAMFSerialize];
    }
    if (!obj)
        return;
    
    // if onAMFSerialize changed the original obj type to another type
    id <ITypeWriter> typeWriter  = [[MessageWriter sharedInstance] getWriter:[obj class] format:writer withInterfaces:YES];
    if (typeWriter) {
        [DebLog log:_ON_WRITERS_LOG_ text:@"ObjectWriter -> write: (*** CHANGED ***) '%@' >> typeWriter:%@", [obj class], typeWriter];
        [typeWriter write:obj format:writer];
        return;
    }
    
    // NSNumber correction bridged from swift Bool on 32-bit device/simulator    
    NSMutableDictionary *objectFields = [NSMutableDictionary dictionaryWithDictionary:[Types propertyDictionary:obj]];
    NSDictionary *attrs = [Types propertyKeysWithAttributes:obj];
    NSArray *props = [objectFields allKeys];
    
    // property to field mapping
    NSDictionary *fieldMappings = [[Types sharedInstance] getPropertiesMappingForClientClass:[obj class]];    
    for (NSString *fieldName in [fieldMappings allKeys]) {
        NSString *propName = [fieldMappings valueForKey:fieldName];
        
        if ([[objectFields allKeys] containsObject:propName]) {
            [objectFields setObject:[objectFields valueForKey:propName] forKey:fieldName];
            [objectFields removeObjectForKey:propName];
        }
    }
    
    for (NSString *prop in props) {
        id field = objectFields[prop];
        if ([field isKindOfClass:NSNumber.class]) {
            NSNumber *number = (NSNumber *)field;
            char propCode = [self propertyCode:attrs[prop]];
            char cType = [number objCType][0];
            if (propCode == 'c' && cType == 'i') {
                objectFields[prop] = [number boolValue]?@(YES):@(NO);
                [DebLog log:_ON_WRITERS_LOG_ text:@"ObjectWriter -> write (!!! NSNumber CORRECTION !!!): %@ = '%c'<->'%c'", prop, propCode, cType];
            }
        }
    }
    
    NSString *className = [__types objectMappedClassName:obj];
    
    [DebLog log:_ON_WRITERS_LOG_ text:@"ObjectWriter -> write: className = '%@'", className];
    
    id <IObjectSerializer> serializer = [writer getObjectSerializer];
    [serializer writeObject:className fields:objectFields format:writer];
}

-(char)propertyCode:(NSString *)attributes {
    const char *attr = [attributes UTF8String];
    return (attributes && (attributes.length > 1) && attr[0] == 'T') ? attr[1] : 0;
}

@end
