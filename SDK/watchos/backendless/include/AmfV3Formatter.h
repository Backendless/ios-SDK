//
//  AmfV3Formatter.h
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

#import <Foundation/Foundation.h>
#import "IProtocolFormatter.h"
#import "V3ReferenceCache.h"
#import "IObjectSerializer.h"

@interface AmfV3Formatter : IProtocolFormatter {
	NSMutableDictionary     *writers;
    id <IObjectSerializer>  objectSerializer;
	V3ReferenceCache        *referenceCache;
}

-(void)addTypeWriter:(Class)mappedType writer:(id <ITypeWriter>)typeWriter;
-(void)writeByteArray:(NSData *)array;
-(void)writeDouble:(double)number withMarker:(BOOL)writeMarker;
-(void)writeUncompressedUInteger:(uint)number;
-(void)writeUncompressedInteger:(int)number;
-(void)writeVarIntWithoutMarker:(int)number;
-(void)writeString:(NSString *)s withMarker:(BOOL)writeMarker;
@end
