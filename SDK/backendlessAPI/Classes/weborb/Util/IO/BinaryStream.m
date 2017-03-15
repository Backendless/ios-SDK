//
//  BinaryStream.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "BinaryStream.h"
#import "DEBUG.h"


@implementation BinaryStream
@synthesize buffer, size, position, error;

-(id)init {	
	if ( (self=[super init]) ) {
		buffer = nil;
		size = 0;
		position = 0;
        error = 0;
	}
	
	return self;
}

-(id)initWithStream:(char *)stream andSize:(size_t)length {	
	if ( (self=[super init]) ) {
		buffer = malloc(length);
		memmove(buffer, stream, length);
		size = length;
		position = 0;
        error = 0;
	}
	
	return self;
}

-(id)initWithAllocation:(size_t)length {	
	if ( (self=[super init]) ) {
		buffer = malloc(length);
		memset(buffer, 0, length);
		size = length;
		position = 0;
        error = 0;
	}
	
	return self;
}

+(id)streamWithStream:(char *)stream andSize:(size_t)length {
    return [[[BinaryStream alloc] initWithStream:stream andSize:length] autorelease];
}

+(id)streamWithAllocation:(size_t)length {
    return [[[BinaryStream alloc] initWithAllocation:length] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC BinaryStream"];
	
	if (buffer)
		free(buffer);

	[super dealloc];
}

#pragma mark -
#pragma mark Debug Methods

-(void)print {
    [self print:[DebLog getIsActive]];
}

-(void)print:(BOOL)visable {
#if 0
    if (!visable || !buffer)
        return;
    
    int i, n = 0;
    for (i = 0; i < size; i++) {
        if (i % 16 == 0) { 
            printf("  "); 
            for (; n < i; n++) {
                if (buffer[n] >= 0x20)
                    printf("%c", (char)buffer[n]); 
                else
                    printf(".");
            }
            printf("\n");
        }
        printf("%02x ", (uint)buffer[i]%0x100);
    }
    
    while (i % 16 != 0) {
        printf("   "); 
        i++;
    }
    
    printf("  "); 
    for (; n < size; n++) {
        if (buffer[n] >= 0x20)
            printf("%c", (char)buffer[n]); 
        else
            printf(".");
    }
    
    printf("\n\n");
#else
    [self print:visable start:0 finish:(size-1)];
#endif
}

-(void)print:(BOOL)visable start:(int)start finish:(int)finish {
    
    if (!visable || !buffer)
        return;
    
    if (finish >= size)
        finish = size - 1;
    
    if ((start > finish) || (start >= size)) {
        printf("print ERROR size: %zu, start: %d, finish: %d\n", size, start, finish);
        return;
    }
    
    int len = 1 - start + finish;
    
    int i, n = 0;
    for (i = 0; i < len; i++) {
        if (i % 16 == 0) {
            printf("  ");
            for (; n < i; n++) {
                if (buffer[start+n] >= 0x20)
                    printf("%c", (char)buffer[start+n]);
                else
                    printf(".");
            }
            printf("\n");
        }
        printf("%02x ", (uint)buffer[start+i]%0x100);
    }
    
    while (i%16) {
        printf("   ");
        i++;
    }
    
    printf("  ");
    for (; n < len; n++) {
        if (buffer[start+n] >= 0x20)
            printf("%c", (char)buffer[start+n]);
        else
            printf(".");
    }
    printf("\n\n");
}

#pragma mark -
#pragma mark Public Methods

+(void)invertOrder:(char *)stream ofSize:(size_t)length {
	
    if (!stream || length < 2)
		return;
	
	for (int i = 0; i < length/2; i++) {
        int pos = length-i-1;
		char chr = stream[i];
		stream[i] = stream[pos];
		stream[pos] = chr;
	}
}

-(BOOL)extend:(size_t)length {
    
    error = 0;
	
	if (!buffer) {
		
        buffer = malloc(length);
        if (buffer) {
            size = length;
            position = 0;
            return YES;
        }
        
        error = 2;
		return NO;
	}
	
	char *tmp = malloc(size+length);
	if (!tmp) {
        error = 2;
		return NO;
    }
	
	memmove(tmp, buffer, size);
	memset(&tmp[size], 0, length);
	free(buffer);
	buffer = tmp;
	size += length;

	return YES;
}

-(BOOL)extendTo:(size_t)length {
    int ext = buffer ? length - (size - position) : length;
	return (!buffer || (ext > 0)) ? [self extend:ext] : YES;
}

-(int)remaining {
	int remain = buffer ? size - position : 0;
	return (remain > 0) ? remain : 0;
}

-(BOOL)seek:(unsigned int)pos {
	
	if (!buffer || (pos > size))
		return NO;
	
	position = pos;
	return YES;
}

-(BOOL)begin {
	return [self seek:0];
}

-(BOOL)end {
	return [self seek:size];
}

-(BOOL)next {
	return [self seek:position+1];
}

-(BOOL)previous {
	
	if (position == 0)
		return NO;
	
	return [self seek:position-1];
}

-(BOOL)put:(char)value {
	
	if (!buffer || (position >= size))
		return NO;

	buffer[position] = value;
	return YES;
}

-(char)get {
	return (buffer && (position < size)) ? buffer[position] : 0;
}

-(int)shift {
	
    if (!buffer || (position == 0) || (position >= size))
		return 0;
	
	size -= position;
    memmove(buffer, &buffer[position], size);
	position = 0;
	
	return size;
}

-(int)trunc {
	return buffer ? (size = position) : 0;
}

-(int)move:(int)shift {
	
	if (!buffer || (position >= size) || (((int)position + shift) < 0))
		return 0;
  	  
    if (shift > 0) {
        size_t _size = size - 1;
        [self extendTo:shift];
        for (int i = _size; i >= position; i--) 
            buffer[i+shift] = buffer[i];	
    }
    else {
        for (int i = position; i < size; i++) 
            buffer[i+shift] = buffer[i];	
        size += shift;
        position += shift;
    }	
	return shift;
}

-(BOOL)append:(char *)buf length:(size_t)length {
	
    int bound = size;
	if (!buf || !length || ![self extend:length])
		return NO;

    memmove(&buffer[bound], buf, length);
	return YES;
}

-(void)empty {
    [self begin];
    [self trunc];
}

-(void)clear {
	
	if (buffer)
		free(buffer);
	
	buffer = nil;
	size = 0;
	position = 0;
}

@end


@implementation BinaryWriter : BinaryStream

#pragma mark -
#pragma mark Public Methods

-(BOOL)extendForWrite:(size_t)length {
    return [self extendTo:length];
}

-(BOOL)write:(char *)buf length:(size_t)length {
	
	if (!buf || !length || ![self extendForWrite:length])
		return NO;
	
    memmove(&buffer[position], buf, length);
	position += length;
	return YES;
}

-(BOOL)writeByte:(int)value {
	u_double_t number;
	number._long = value;
	return [self write:number._buf length:1];
}

-(BOOL)writeInt16:(short)value {
	u_double_t number;
	number._long = value;
	return [self write:number._buf length:2];
}

-(BOOL)writeInt32:(int)value {
	u_double_t number;
	number._long = value;
	return [self write:number._buf length:4];
}

-(BOOL)writeInt64:(long)value {
	u_double_t number;
	number._long = value;
	return [self write:number._buf length:8];
}

-(BOOL)writeDouble:(double)value {
	u_double_t number;
	number._double = value;
	return [self write:number._buf length:8];
}

-(BOOL)writeBoolean:(BOOL)value {
	return [self writeChar:(char)value];
}

-(BOOL)writeChar:(char)value {
	
    if (![self extendForWrite:1])
		return NO;
	
	buffer[position] = value;
	position++;
	return YES;
}

-(BOOL)writeChars:(char *)str {
	return (str && str[0]) ? [self write:str length:strlen(str)] : NO;
}

@end


@implementation BinaryReader : BinaryStream

#pragma mark -
#pragma mark Public Methods

-(int)read:(char *)buf length:(size_t)length {
    
    if (!buffer || !buf || !length) {
        error = 2;
		return 0;
    }
	
    int len = (size - position > length) ? length : (size - position);
    memmove(buf, &buffer[position], len);
	position += len;
    error = 0;
	return len;
}

-(int)readByte {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
	
    if (position >= size) {
        error = 1;
		return 0;
    }
	
	int value = (unsigned char)buffer[position];
	position++;
    error = 0;
	return value;
}

-(int)readInt16 {
    
    if (!buffer) {
        error = 2;
		return 0;
    }

	if (size - position < 2) {
        error = 1;
		return 0;
    }
	
	int value = 0; 
    char *p = (char *)&value;
	for (int i = 0; i < 2; i++)
        p[i] = buffer[i+position];

	position += 2;
    error = 0;
	return value;
}

-(uint)readUInt24BE {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (size - position < 3) {
        error = 1;
		return 0;
    }
	
	uint value = 0; 
    
    value = ((unsigned char)buffer[position])<<16;    
    value += ((unsigned char)buffer[position+1])<<8; 
    value += (unsigned char)buffer[position+2];
    
	position += 3;
    error = 0;
	return value;
}

-(uint)readUInt32BE {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (size - position < 4) {
        error = 1;
		return 0;
    }
    
    uint value = (((unsigned char)buffer[position])<<24) + (((unsigned char)buffer[position+1])<<16) + (((unsigned char)buffer[position+2])<<8) + (unsigned char)buffer[position+3];
    
    position+=4;
    error = 0;
    return value;
}

-(uint)readExtendedMediumUIntBE {
    uint value = [self readUInt32BE];
    value = (value >> 8) | ((value & 0x000000ff) << 24);
    return value;
}

-(int)readInt32 {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (size - position < 4) {
        error = 1;
		return 0;
    }
	
	int value = 0; 
    char *p = (char *)&value;
	for (int i = 0; i < 4; i++)
        p[i] = buffer[i+position];
    
	position += 4;
    error = 0;
	return value;
}

-(long)readInt64 {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (size - position < 8) {
        error = 1;
		return 0;
    }
	
	u_double_t value;
	[self read:(char *)&value._buf length:8];
	return value._long;
}

-(double)readDouble {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (size - position < 8) {
        error = 1;
		return 0;
    }
	
	u_double_t value;
	[self read:(char *)&value._buf length:8];
	return value._double;
}

-(BOOL)readBoolean {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (position >= size) {
        error = 1;
		return NO;
    }
	
	BOOL value = (BOOL)buffer[position];
	position++;
    error = 0;
	return value;
}

-(char)readChar {
    
    if (!buffer) {
        error = 2;
		return 0;
    }
    
	if (position >= size) {
        error = 1;
		return 0;
    }
	
	char value = buffer[position];
	position++;
    error = 0;
	return value;
}

// !!! Need to be free after using !!!
-(char *)readChars:(int)count {
	
    char *str = malloc(count+1);
	if (!str) {
        error = 2;
		return nil;
    }
	
	memset(str, 0, count+1);
	[self read:str length:count];
	return str;
}

@end

