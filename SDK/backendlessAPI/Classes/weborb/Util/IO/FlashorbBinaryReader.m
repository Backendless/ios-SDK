//
//  FlashorbBinaryReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "FlashorbBinaryReader.h"
#import "DEBUG.h"

@implementation FlashorbBinaryReader

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC FlashorbBinaryReader"];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(int)readVarInteger {
    
    if (!buffer) {
        error = 2;
        return 0;
    }
    
    int num = [self readByte] & 0xFF;
    if (error)
        return -1;
    if (num < 128)
        return num;
    
    int val = (num & 0x7F) << 7;
    num = [self readByte] & 0xFF;
    if (error)
        return -1;
    if (num < 128)
        return val | num;
    
    val = (val | (num & 0x7F)) << 7;
    num = [self readByte] & 0xFF;
    if (error)
        return -1;
    if (num < 128)
        return val | num;
    
    val = (val | (num & 0x7F)) << 8;
    num = [self readByte] & 0xFF;
    if (error)
        return -1;
    return val | num;
}

-(unsigned int)readUnsignedShort {
    
    if (!buffer) {
        error = 2;
        return 0;
    }
    
    if (size - position < 2) {
        error = 1;
        return 0;
    }
    
    unsigned int value = 0;
    char *p = (char *)&value;
    for (int i = 0; i < 2; i++)
        p[1-i] = buffer[i+position];
    position += 2;
    error = 0;
    return value;
}

-(unsigned int)readUInt24 {
    
    if (!buffer) {
        error = 2;
        return 0;
    }
    
    if (size - position < 3) {
        error = 1;
        return 0;
    }
    
    unsigned int value = 0;
    char *p = (char *)&value;
    for (int i = 0; i < 3; i++)
        p[2-i] = (unsigned char)buffer[i+position];
    position += 3;
    error = 0;
    return value;
}

-(unsigned int)readUInteger {
    
    if (!buffer) {
        error = 2;
        return 0;
    }
    if (size - position < 4) {
        error = 1;
        return 0;
    }
    
    unsigned int value = 0;
    char *p = (char *)&value;
    for (int i = 0; i < 4; i++)
        p[3-i] = buffer[i+position];
    position += 4;
    error = 0;
    return value;
}

-(int)readInteger {
    
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
        p[3-i] = buffer[i+position];
    position += 4;
    error = 0;
    return value;
}

-(unsigned long)readULong {
    
    if (!buffer) {
        error = 2;
        return 0;
    }
    if (size - position < 8) {
        error = 1;
        return 0;
    }
    
    u_double_t value;
    for (int i = 0; i < 8; i++)
        value._buf[i] = buffer[position +7-i];
    /*/
     printf("********* read uLong ********\n");
     for (int i = 0; i < 8; i++)
     printf("%02x ", (uint)value._buf[i]%0x100);
     printf("\n***********************\n");
     /*/
    position += 8;
    error = 0;
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
    for (int i = 0; i < 8; i++)
        value._buf[i] = buffer[position +7-i];
    /*/
     printf("********* read double ********\n");
     for (int i = 0; i < 8; i++)
     printf("%02x ", (uint)value._buf[i]%0x100);
     printf("\n***********************\n");
     /*/
    position += 8;
    error = 0;
    return value._double;
}

// !!! Need to be free after using !!!
-(char *)readUTF {
    unsigned short len = [self readUnsignedShort];
    //printf("readUTF->len=%d\n", (int)len);
    return [self readUTF:len];
}

#if 0
// !!! Need to be free after using !!!
-(char *)readUTF:(int)len {
    return [self readChars:len];
}
#else

// !!! Need to be free after using !!!
-(char *)readUTF:(int)len {
    char *utf8str = [self readChars:len];
    return utf8str;
}
#endif

-(NSString *)readString {
    char *utf8str = [self readUTF];
    if (utf8str) {
        NSString *str = [NSString stringWithUTF8String:utf8str];
        free(utf8str);
        return str;
    }    
    return [NSString string];
}

@end
