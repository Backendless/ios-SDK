//
//  ITypeWriter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

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
