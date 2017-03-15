//
//  V3ArrayReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3ArrayReader.h"
#import "DEBUG.h"
#import "AnonymousObject.h"
#import "ArrayType.h"
#import "RequestParser.h"
#import "ReaderUtils.h"


@implementation V3ArrayReader

+(id)typeReader {
	return [[[V3ArrayReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ArrayReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    [DebLog log:_ON_READERS_LOG_ text:@"V3ArrayReader  -> read:context: (START)"];
   
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0) {
#if 1
        refId = refId >> 1;
        id <IAdaptingType> ref = [parseContext getReference:refId];
        [DebLog log:_ON_READERS_LOG_ text:@"V3ArrayReader -> read: (+++++ REFERENCE) refId=%d -> %@", refId, ref];
        return ref;
#else
        return [parseContext getReference:(refId >> 1)];
#endif
    }
	
	int arraySize = (refId >> 1);
    id <IAdaptingType> adaptingType = nil;
    id container = nil;
    
	while (YES) {
        
        NSString *str = [ReaderUtils readString:reader context:parseContext];
		if (!str || !str.length)
			break;
        
        if (!container) {
            NSMutableDictionary *container = [NSMutableDictionary dictionary];
            adaptingType = [AnonymousObject objectType:container];
            [parseContext addReference:adaptingType];
        }
		
		id <IAdaptingType> obj = [RequestParser readData:reader context:parseContext];		
		[DebLog log:_ON_READERS_LOG_ text:@"V3ArrayReader -> read:(A) '%@' -> %@", str, obj];
		if (!obj)
			break;
		
#if _ADAPT_DURING_PARSING_
        if ((obj = [obj defaultAdapt]))
            [container setObject:obj forKey:str];
#else
        [container setObject:obj forKey:str];
#endif
	}
    
    if (!adaptingType) {
        container = [NSMutableArray array];
        adaptingType = [ArrayType objectType:container];
        [parseContext addReference:adaptingType];
        
        for (int i = 0; i < arraySize; i++) {
            id <IAdaptingType> obj = [RequestParser readData:reader context:parseContext];		
            [DebLog log:_ON_READERS_LOG_ text:@"V3ArrayReader -> read:(B) %d -> %@", i, obj];
            if (!obj)
                break;
            
#if _ADAPT_DURING_PARSING_
            if ((obj = [obj defaultAdapt]))
                [container addObject:obj];
#else
            [container addObject:obj];
#endif
        }
    }
    else {
        for (int i = 0; i < arraySize; i++) {
            id <IAdaptingType> obj = [RequestParser readData:reader context:parseContext];		
            [DebLog log:_ON_READERS_LOG_ text:@"V3ArrayReader -> read:(C) '%d' -> %@", i, obj];
            if (!obj)
                break;
            
#if _ADAPT_DURING_PARSING_
            if ((obj = [obj defaultAdapt]))
                [container setObject:obj forKey:[NSString stringWithFormat:@"%d",i] ];
#else
            [container setObject:obj forKey:[NSString stringWithFormat:@"%d",i] ];
#endif
        }
    }
	
	return adaptingType;
}

@end
