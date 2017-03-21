//
//  Datatypes.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

typedef enum amf_protocol_encoding ProtocolEncoding;
typedef enum amf0_datatype amf0_datatype_t;
typedef enum amf3_datatype amf3_datatype_t;
typedef enum rtmp_datatype rtmp_datatype_t;

enum amf_protocol_encoding
{
	AMF0 = 0,
	AMF3 = 3,
};

enum amf0_datatype
{
	NUMBER_DATATYPE_V1 = 0,				// 0x00
	BOOLEAN_DATATYPE_V1 = 1,			// 0x01
	UTFSTRING_DATATYPE_V1 = 2,			// 0x02
	OBJECT_DATATYPE_V1 = 3,				// 0x03
	NULL_DATATYPE_V1 = 5,				// 0x05
	UNKNOWN_DATATYPE_V1 = 6,			// 0x06
	POINTER_DATATYPE_V1 = 7,			// 0x07
	OBJECTARRAY_DATATYPE_V1 = 8,		// 0x08
	ENDOFOBJECT_DATATYPE_V1 = 9,		// 0x09
	ARRAY_DATATYPE_V1 = 10,				// 0x0A
	DATE_DATATYPE_V1 = 11,				// 0x0B
	LONGUTFSTRING_DATATYPE_V1 = 12,		// 0x0C
	REMOTEREFERENCE_DATATYPE_V1 = 13,	// 0x0D
	RECORDSET_DATATYPE_V1 = 14,			// 0x0E
	PARSEDXML_DATATYPE_V1 = 15,			// 0x0F
	NAMEDOBJECT_DATATYPE_V1 = 16,		// 0x10
	V3_DATATYPE = 17,					// 0x11
	TOTAL_V1TYPES = 18,					// 0x12
};

enum amf3_datatype
{
	UNKNOWN_DATATYPE_V3 = 0,			// 0x00
	NULL_DATATYPE_V3 = 1,				// 0x01
	BOOLEAN_DATATYPE_FALSEV3 = 2,		// 0x02
	BOOLEAN_DATATYPE_TRUEV3 = 3,		// 0x03
	INTEGER_DATATYPE_V3 = 4,			// 0x04
	DOUBLE_DATATYPE_V3 = 5,				// 0x05
	UTFSTRING_DATATYPE_V3 = 6,			// 0x06
	XML_DATATYPE_V3 = 7,				// 0x07
	DATE_DATATYPE_V3 = 8,				// 0x08
	ARRAY_DATATYPE_V3 = 9,				// 0x09
	OBJECT_DATATYPE_V3 = 10,			// 0x0A
	LONGXML_DATATYPE_V3 = 11,			// 0x0B
	BYTEARRAY_DATATYPE_V3 = 12,			// 0x0C
    INT_VECTOR_V3 = 13,					// 0x0D
    UINT_VECTOR_V3 = 14,				// 0x0E
    DOUBLE_VECTOR_V3 = 15,				// 0x0F
    OBJECT_VECTOR_V3 = 16,				// 0x10
    TOTAL_V3TYPES = 17,					// 0x11
};


enum rtmp_datatype
{
    RTMP_DATATYPE_SKIPTYPE = 0,			// 0x00
    RTMP_DATATYPE_NULL = 1,				// 0x01
    RTMP_DATATYPE_BOOLEAN = 2,			// 0x02
    RTMP_DATATYPE_NUMBER = 3,			// 0x03
    RTMP_DATATYPE_STRING = 4,			// 0x04
    RTMP_DATATYPE_DATE = 5,				// 0x05
    RTMP_DATATYPE_ARRAY = 6,			// 0x06
    RTMP_DATATYPE_MAP = 7,				// 0x07
    RTMP_DATATYPE_XML = 8,				// 0x08
    RTMP_DATATYPE_OBJECT = 9,			// 0x09
    RTMP_DATATYPE_REFERENCE = 10,		// 0x0A
    TOTAL_RTMPTYPES = 11,				// 0x0B
};
