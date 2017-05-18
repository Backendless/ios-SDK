//
//  FlashorbBinaryWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 22.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "FlashorbBinaryWriter.h"
#import "DEBUG.h"

@implementation FlashorbBinaryWriter

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC FlashorbBinaryWriter"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(BOOL)writeInvertInt:(int)value rang:(unsigned int)rang {
  	
    if (![self extendForWrite:rang])
		return NO;
    
    for (int i = (rang - 1); i >= 0; i--)
        if (![self writeByte:(value>>(8*i))%0x100])
            return NO;
    
    return YES;
}

#pragma mark -
#pragma mark Public Methods

-(BOOL)writeUInteger:(unsigned int)value {
    return [self writeInvertInt:value rang:4];
}

-(BOOL)writeUInt16:(unsigned short)value {
    return [self writeInvertInt:value rang:2];
}

-(BOOL)writeUInt24:(unsigned int)value {
    return [self writeInvertInt:value rang:3];
}

-(BOOL)writeInt:(int)value {
    return [self writeInvertInt:value rang:4];
}

// overrided
-(BOOL)writeDouble:(double)value {
	if (![self extendForWrite:8])
		return NO;
	u_double_t number;
	number._double = value;
	/*/
     printf("********* double ********\n");
     for (int i = 0; i < 8; i++) 
     printf("%02x ", (uint)number._buf[i]%0x100);
     printf("\n***********************\n");
     /*/
	for (int i = 7; i >= 0; i--) {
		if (![self writeByte:number._buf[i]])
			return NO;
	}
	return YES;
}

-(BOOL)writeLong:(long)value {
	if (![self extendForWrite:8])
		return NO;
	u_double_t number;
	number._long = value;
	for (int i = 4; i < 8; i++) 
		number._buf[i] = (value >= 0) ? 0x0 : 0xff;
	/*/
	printf("********* long ********\n");
	for (int i = 0; i < 8; i++) 
		printf("%02x ", (uint)number._buf[i]%0x100);
	printf("\n***********************\n");
	/*/
	for (int i = 7; i >= 0; i--) {
		if (![self writeByte:number._buf[i]])
			return NO;
	}
	return YES;
}

-(BOOL)writeVarInt:(int)value {	
	if (value < 128)
		return [self writeByte:value];
	else if (value < 16384) {
		return [self writeByte:((value>>7)%0x80|0x80)] && [self writeByte:(value%0x80)];
	}
	else if (value < 2097152) {
		return [self writeByte:((value>>14)%0x80|0x80)] && [self writeByte:((value>>7)%0x80|0x80)] && [self writeByte:(value%0x80)];
	}
	else if (value < 1073741824) {
		return [self writeByte:((value>>22)%0x80|0x80)] && [self writeByte:((value>>15)%0x80|0x80)] && 
				[self writeByte:((value>>8)%0x80|0x80)] && [self writeByte:(value%0x100)];
	}
	return NO;
}

-(BOOL)writeString:(NSString *)str {
	
    if (!str)
		return NO;
    
    const char *cstr = [str UTF8String];
    size_t len = strlen(cstr);
	
    [DebLog logN:@"FlashorbBinaryWriter -> writeString: str.lenght = %d, len = %d", str.length, len];

	return (len) ? [self writeUInt16:len] && [self write:(char *)cstr length:len] : NO;
}

-(BOOL)writeLongString:(NSString *)str {
	
    if (!str)
		return NO;
    
    const char *cstr = [str UTF8String];
    size_t len = strlen(cstr);
	
    [DebLog log:@"FlashorbBinaryWriter -> writeLongString: str.lenght = %d, len = %d", str.length, len];
    
	return (unsigned int)(len) ? [self writeUInteger:(unsigned int)len] && [self write:(char *)cstr length:len] : NO;
}

-(BOOL)writeStringEx:(NSString *)str {
	
    if (!str)
		return NO;
    
    const char *cstr = [str UTF8String];
    size_t len = strlen(cstr);
	
    [DebLog logN:@"FlashorbBinaryWriter -> writeStringEx: str.lenght = %d, len = %d", str.length, len];
    
	return (len) ? [self writeVarInt:(int)((len << 1)|0x1)] && [self write:(char *)cstr length:len] : NO;
}

@end
