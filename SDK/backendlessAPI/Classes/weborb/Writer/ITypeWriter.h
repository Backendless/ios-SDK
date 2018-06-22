//
//  ITypeWriter.h
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

#define _ON_WRITERS_LOG_ NO

#define _ON_REFERENCEBLE_TYPE_WRITER_ 1
#define _ON_REFERENCEBLE_STRING_WRITER_ 1
#define _ON_EQUAL_BY_INSTANCE_ADDRESS_ 1
#define _ON_EQUAL_BY_STRING_VALUE_ 1

@class IProtocolFormatter;

@protocol ITypeWriter <NSObject>
+(id)writer;
-(void)write:(id)obj format:(IProtocolFormatter *)formatter;
-(id <ITypeWriter>)getReferenceWriter;
@end
