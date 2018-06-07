//
//  FlashorbBinaryReader.m
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
    position += 8;
    error = 0;
    return value._double;
}

// !!! Need to be free after using !!!
-(char *)readUTF {
    unsigned short len = [self readUnsignedShort];
    return [self readUTF:len];
}

// !!! Need to be free after using !!!
-(char *)readUTF:(int)len {
    char *utf8str = [self readChars:len];
    return utf8str;
}

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
