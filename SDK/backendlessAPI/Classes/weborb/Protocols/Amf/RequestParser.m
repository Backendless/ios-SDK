//
//  RequestParser.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "RequestParser.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "ITypeReader.h"
#import "BooleanReader.h"
#import "NumberReader.h"
#import "IntegerReader.h"
#import "PointerReader.h"
#import "DateReader.h"
#import "UTFStringReader.h"
#import "LongUTFStringReader.h"
#import "AnonymousObjectReader.h"
#import "NullReader.h"
#import "UndefinedTypeReader.h"
#import "NotAReader.h"
#import "NamedObjectReader.h"
#import "ArrayReader.h"
#import "BoundPropertyBagReader.h"
#import "V3Reader.h"
#import "V3DateReader.h"
#import "V3StringReader.h"
#import "V3ArrayReader.h"
#import "V3ByteArrayReader.h"
#import "V3ObjectReader.h"
#import "V3VectorReader.h"
#import "Body.h"
#import "AmfFormatter.h"
#import "AmfV3Formatter.h"


@interface RequestParser ()
+(id <ITypeReader>)typeReader:(int)version typeData:(int)type;
+(MHeader *)readHeader:(FlashorbBinaryReader *)reader;
+(Body *)readBodyPart:(FlashorbBinaryReader *)reader;
@end;

@implementation RequestParser

#pragma mark -
#pragma mark Public Methods

+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader {
    return [RequestParser readData:reader version:AMF0];
}

+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader version:(int)version {
    
    ParseContext *parseContext = [[ParseContext alloc] initWithVersion:version];
    id <IAdaptingType> object = [RequestParser readData:reader context:parseContext];
    [parseContext release];
    return object;
}

+(id <IAdaptingType>)readData:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
	
	if (!reader || !parseContext)
		return nil;
	
	[DebLog logN:@"****************> RequestParser -> reader.position: %d", reader.position];
		
	int version = [parseContext getVersion];
	int type = [reader readByte];
	id <ITypeReader> typeReader = [RequestParser typeReader:version typeData:type];
	id <IAdaptingType> object = (typeReader) ? [typeReader read:reader context:parseContext] : nil;
	
	//[DebLog logN:@"****************> RequestParser -> typeReader: '%@' object: '%@'", typeReader.description, object.description];
	
	return object;
}

+(Request *)readMessage:(FlashorbBinaryReader *)reader {
    
    [DebLog log:_ON_READERS_LOG_ text:@"RequestParser -> readMessage: ($$$$$----------------------------------------- START)"];
    
    int version = [reader readUnsignedShort];
    
    int totalHeaders = [reader readUnsignedShort];
    NSMutableArray *headers = [NSMutableArray array];
    for (int i = 0; i < totalHeaders; i++) {
        MHeader *header = [RequestParser readHeader:reader];
        if (!header) {
            [DebLog logY:@"RequestParser -> readMessage: ERROR: break HEADERS"];
            return nil;
        }
        [headers addObject:header];
    }
    
    int totalBodyParts = [reader readUnsignedShort];
    NSMutableArray *bodies = [NSMutableArray array];
    for (int i = 0; i < totalBodyParts; i++) {
        Body *body = [RequestParser readBodyPart:reader];
        if (!body) {
            [DebLog logY:@"RequestParser -> readMessage: ERROR: break BODIES"];
            return nil;
        }
        
        [DebLog log:_ON_READERS_LOG_ text:@"RequestParser -> readMessage: add body %@", body.dataObject];
        
        [bodies addObject:body];
    }
    
    [DebLog log:_ON_READERS_LOG_ text:@"RequestParser -> readMessage: ($$$$$------------------------------------------- FINISH)\nversion=%d, headers=%d, bodies=%d", version, headers.count, bodies.count];
    
    Request *request = [Request request:(float)version headers:headers bodies:bodies];
    [request setFormatter:(version == AMF3) ? [AmfV3Formatter formatter] : [AmfFormatter formatter]];
   
    return request;
}


#pragma mark -
#pragma mark Private Methods

+(id <ITypeReader>)typeReader:(int)version typeData:(int)type {
	
	[DebLog log:_ON_READERS_LOG_ text:@"RequestParser -> typeReader: version = %d, type = %d", version, type];
	
	id <ITypeReader> typeReader = nil;
	
	if (version == AMF0) {
		switch (type) {
			case NUMBER_DATATYPE_V1:
				typeReader = [NumberReader typeReader];
				break;
			case BOOLEAN_DATATYPE_V1:
                typeReader = [BooleanReader typeReader];
				break;
			case UTFSTRING_DATATYPE_V1:
				typeReader = [UTFStringReader typeReader];
				break;
			case OBJECT_DATATYPE_V1:
				typeReader = [AnonymousObjectReader typeReader];
				break;
			case NULL_DATATYPE_V1:
				typeReader = [NullReader typeReader];
				break;
			case UNKNOWN_DATATYPE_V1:
				typeReader = [UndefinedTypeReader typeReader];
				break;
			case POINTER_DATATYPE_V1:
				typeReader = [PointerReader typeReader];
				break;
			case OBJECTARRAY_DATATYPE_V1:
				typeReader = [BoundPropertyBagReader typeReader];
				break;
			case ENDOFOBJECT_DATATYPE_V1:
				typeReader = [NotAReader typeReader];
				break;
			case ARRAY_DATATYPE_V1:
				typeReader = [ArrayReader typeReader];
				break;
			case DATE_DATATYPE_V1:
				typeReader = [DateReader typeReader];
				break;
			case LONGUTFSTRING_DATATYPE_V1:
				typeReader = [LongUTFStringReader typeReader];
				break;
			case REMOTEREFERENCE_DATATYPE_V1:
				break;
			case RECORDSET_DATATYPE_V1:
				break;
			case PARSEDXML_DATATYPE_V1:
				break;
			case NAMEDOBJECT_DATATYPE_V1:
				typeReader = [NamedObjectReader typeReader];
				break;
			case V3_DATATYPE:
				typeReader = [V3Reader typeReader];
				break;
			default:
				break;
		}
	}
	
	if (version == AMF3) {
		switch (type) {
			case UNKNOWN_DATATYPE_V3:
				typeReader = [UndefinedTypeReader typeReader];
				break;
			case NULL_DATATYPE_V3:
				typeReader = [NullReader typeReader];
				break;
			case BOOLEAN_DATATYPE_FALSEV3:
                typeReader = [BooleanReader typeReader:NO];
				break;
			case BOOLEAN_DATATYPE_TRUEV3:
                typeReader = [BooleanReader typeReader:YES];
				break;
			case INTEGER_DATATYPE_V3:
				typeReader = [IntegerReader typeReader];
				break;
			case DOUBLE_DATATYPE_V3:
				typeReader = [NumberReader typeReader];
				break;
			case UTFSTRING_DATATYPE_V3:
				typeReader = [V3StringReader typeReader];
				break;
			case XML_DATATYPE_V3:
				break;
			case DATE_DATATYPE_V3:
				typeReader = [V3DateReader typeReader];
				break;
			case ARRAY_DATATYPE_V3:
				typeReader = [V3ArrayReader typeReader];
				break;
			case OBJECT_DATATYPE_V3:
				typeReader = [V3ObjectReader typeReader];
				break;
			case LONGXML_DATATYPE_V3:
				break;
			case BYTEARRAY_DATATYPE_V3:
				typeReader = [V3ByteArrayReader typeReader];
				break;
			case INT_VECTOR_V3:
			case UINT_VECTOR_V3:
			case DOUBLE_VECTOR_V3:
			case OBJECT_VECTOR_V3:
				typeReader = [V3VectorReader typeReader:type];
				break;
			case V3_DATATYPE:
				typeReader = [V3Reader typeReader];
				break;
			default:
				break;
		}
	}
	
	return typeReader;
}

+(MHeader *)readHeader:(FlashorbBinaryReader *)reader {
    
    NSString *headerName = [reader readString];
    BOOL mustUnderstand = [reader readBoolean];
    int length = [reader readInteger];
    
    [DebLog logN:@"RequestParser -> readHeader: headerName='%@', must=%@, length=%d", headerName, (mustUnderstand)?@"YES":@"NO", length];
    
    return [MHeader headerWithObject:[RequestParser readData:reader] name:headerName understand:mustUnderstand length:length];
}

+(Body *)readBodyPart:(FlashorbBinaryReader *)reader {
    
    NSString *serviceURI = [reader readString];
    NSString *responseURI = [reader readString];
    int length = [reader readInteger];
    
    [DebLog logN:@"RequestParser -> readBodyPart: serviceURI='%@', responseURI='%@', length=%d", serviceURI, responseURI, length];
    
    return [Body bodyWithObject:[RequestParser readData:reader] serviceURI:serviceURI responseURI:responseURI length:length];
}

@end
