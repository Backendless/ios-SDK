//
//  BinaryCodec.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 08.09.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BinaryCodec.h"
#import "DEBUG.h"

#define ArrayLength(x) (sizeof(x)/sizeof(*(x)))

@implementation BEBase64

static char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];

+(void)initialize {
	if (self == [BEBase64 class]) {
		memset(decodingTable, 0, ArrayLength(decodingTable));
		for (NSInteger i = 0; i < ArrayLength(encodingTable); i++) {
			decodingTable[encodingTable[i]] = i;
		}
	}
}

+(NSString *)encode:(const uint8_t *)input length:(NSInteger)length {
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;
			
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
		
        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    encodingTable[(value >> 18) & 0x3F];
        output[index + 1] =                    encodingTable[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

+(NSString *)encode:(NSData *)rawBytes {
    return [self encode:(const uint8_t *) rawBytes.bytes length:rawBytes.length];
}

+(NSData *)decode:(const char *)string length:(NSInteger)inputLength {
	
    if ((string == NULL) || (inputLength % 4 != 0)) {
		return nil;
	}
	
	while (inputLength > 0 && string[inputLength - 1] == '=') {
		inputLength--;
	}
	
	NSInteger outputLength = inputLength * 3 / 4;
	NSMutableData* data = [NSMutableData dataWithLength:outputLength];
	uint8_t* output = data.mutableBytes;
	
	NSInteger inputPoint = 0;
	NSInteger outputPoint = 0;
	while (inputPoint < inputLength) {
		char i0 = string[inputPoint++];
		char i1 = string[inputPoint++];
		char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
		char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
		
		output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
		}
		if (outputPoint < outputLength) {
			output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
		}
	}
	
	return data;
}

+(NSData *)decode:(NSString *)string {
	return [self decode:[string cStringUsingEncoding:NSASCIIStringEncoding] length:string.length];
}

+(NSArray *)encodeToStringArray:(NSData *)rawBytes limit:(size_t)limit {
    
    NSMutableArray *result = [NSMutableArray array];
    if (!rawBytes || !limit)
        return result;
   
    NSString *data = [self encode:rawBytes.bytes length:rawBytes.length];
    [DebLog logN:@"BEBase64 -> encodeToStringArray: data = %@", data];
    if (!data)
        return result;
    
    size_t rest, location = 0;
    size_t length = (data.length > limit) ? limit : data.length;
    
    while (location < data.length) {
        NSRange rang = NSMakeRange(location, length);
        [result addObject:[data substringWithRange:rang]];
        location += length;
        rest = data.length - location;
        length = (rest > limit) ? limit : rest;
    } 
    
    return result;
}

+(NSArray *)encodeToStringArray:(NSData *)rawBytes {
    return [self encodeToStringArray:rawBytes limit:DEFAULT_MAX_SIZE];
}

+(NSData *)decodeFromStringArray:(NSArray *)stringArray {
    
    if (!stringArray)
        return nil;
   
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < stringArray.count; i++) 
        [string appendString:[stringArray objectAtIndex:i]];
    
    [DebLog logN:@"BEBase64 -> decodeFromStringArray: data = %@", string];
    
    return [self decode:string];
}

@end

