//
//  V3ObjectSerializer.m
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

#import "V3ObjectSerializer.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "V3ReferenceCache.h"
#import "MessageWriter.h"


@implementation V3ObjectSerializer

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ObjectSerializer"];
 	
	[super dealloc];
}

#pragma mark -
#pragma mark IObjectSerializer Methods

#define PRINT_WRITE_OBJECT_ON 0

-(void)writeObject:(NSString *)className fields:(NSDictionary *)objectFields format:(IProtocolFormatter *)writer {
	
	[DebLog log:_ON_WRITERS_LOG_||PRINT_WRITE_OBJECT_ON text:@"V3ObjectSerializer -> writeObject:'%@' --------->>>\nfields:\n%@\n <<<-------------\n", className, objectFields];
    
    NSArray *fields = [objectFields allKeys];
    V3ReferenceCache *cache = (V3ReferenceCache *)[writer getReferenceCache];
    NSString *traitsClassId = className;
    
    if (!traitsClassId) {
        NSMutableString *sb = [NSMutableString string];
        for (NSString *fieldName in fields) 
            [sb appendFormat:@"%@-",fieldName];
        traitsClassId = fields.count?sb:[NSString stringWithFormat:@"%f", CFAbsoluteTimeGetCurrent()];
    }
    
    [DebLog log:_ON_WRITERS_LOG_||PRINT_WRITE_OBJECT_ON text:@"V3ObjectSerializer -> writeObject: traitsClassId ='%@' *************", traitsClassId];
    
#if PRINT_WRITE_OBJECT_ON
    [DebLog logY:@"V3ObjectSerializer <%@> (START)", className];
    [writer.writer print:YES];
#endif
    
    int ref = [cache getTraitsId:traitsClassId];
    if (ref >= 0) {
        [writer.writer writeByte:OBJECT_DATATYPE_V3];
        [writer.writer writeVarInt:((ref<<2)|0x1)];
        
#if PRINT_WRITE_OBJECT_ON
        [DebLog logY:@"V3ObjectSerializer <%@> (1)", className];
        [writer.writer print:YES];
#endif
    }
    else {
        
        [writer beginWriteNamedObject:className fields:(int)fields.count];
        
        if (!className) {
            [cache addToTraitsCache:traitsClassId];
        }
        
        for (int i = 0; i < fields.count; i++) {
            NSString *fieldName = [fields objectAtIndex:i];
            [writer writeFieldName:fieldName];
#if PRINT_WRITE_OBJECT_ON
            [DebLog logY:@"V3ObjectSerializer fieldName: %d -> %@", i, fieldName];
            [writer.writer print:YES];
#endif
        }
#if PRINT_WRITE_OBJECT_ON
        [DebLog logY:@"V3ObjectSerializer <%@> (2)", className];
        [writer.writer print:YES];
#endif
    }

    for (int i = 0; i < fields.count; i++) {
        NSString *fieldName = [fields objectAtIndex:i];
        id obj = [objectFields valueForKey:fieldName];

#if PRINT_WRITE_OBJECT_ON
        [DebLog logY:@"V3ObjectSerializer <%@> (3) -> %@ = %@", className, fieldName, obj];
#endif
        
        [[MessageWriter sharedInstance] writeObject:obj format:writer];
   }
    
    [writer endWriteNamedObject];

#if PRINT_WRITE_OBJECT_ON
    [DebLog logY:@"V3ObjectSerializer <%@> (FINISH)", className];
    [writer.writer print:YES];
#endif
}

@end
