//
//  ParseContext.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 15.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ParseContext.h"
#import "DEBUG.h"
#import "Datatypes.h"
#import "ITypeReader.h"

@interface ParseContext ()

@end

@implementation ParseContext

-(id)init {	
	
    if ( (self=[super init]) ) {
        references = [NSMutableArray new];
		stringReferences = [NSMutableArray new];
		classInfos = [NSMutableArray new];
		cachedContext = [NSMutableDictionary new];
		
        _version = AMF0;
	}
	
	return self;
}

-(id)initWithVersion:(int)version {
	
    if ( (self=[super init]) ) {
        references = [NSMutableArray new];
		stringReferences = [NSMutableArray new];
		classInfos = [NSMutableArray new];
		cachedContext = [NSMutableDictionary new];
		
        _version = version;
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ParseContext"];

    [references removeAllObjects];
    [references release];
    
    [stringReferences removeAllObjects];
    [stringReferences release];
    
    [classInfos removeAllObjects];
    [classInfos release];
    
    [cachedContext removeAllObjects];
    [cachedContext release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(ParseContext *)getCachedContext:(int)version {
	
    NSNumber *key = [NSNumber numberWithInt:version];
	ParseContext *obj = [cachedContext objectForKey:key];
	if (!obj) {
		obj = [[[ParseContext alloc] initWithVersion:version] autorelease];
		[cachedContext setObject:obj forKey:key];
	}	
	return obj;
}

-(void)addReference:(id <IAdaptingType>)type {
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> addReference: %d -> %@", [references count], type];
	[references addObject:type];
}

-(id <IAdaptingType>)getReference:(int)pointer {
	
    if (!references.count || (pointer >= references.count))
		return nil;
    
    id <IAdaptingType> ref = [references objectAtIndex:pointer];
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> getReference: %d -> %@", pointer, ref];
	
	return ref;
}

-(void)addReference:(id <IAdaptingType>)type atIndex:(int)index {
	
    if (index >= references.count) {
		NSArray *tmp = references;
		references = [[[NSMutableArray alloc] initWithCapacity:index+1] retain];
		[references addObjectsFromArray:tmp];
		[tmp release];
	}
	
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> addReference:atIndex: %d -> %@", index, type];
	[references insertObject:type atIndex:index];
}

-(void)addStringReference:(NSString *)refStr {
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> addStringReference: %d -> %@", [stringReferences count], refStr];
	[stringReferences addObject:refStr];
}

-(NSString *)getStringReference:(int)index {
	
    if (!stringReferences.count || (index >= stringReferences.count)) {
        [DebLog logY:@"ParseContext -> getStringReference: (ERROR) index: %d => count: %d", index, stringReferences.count];
		return nil;
    }
    
    NSString *refStr = [stringReferences objectAtIndex:index];
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> getStringReference: %d -> %@", index, refStr];
	
	return refStr;
}

-(void)addClassInfoReference:(id)val {
	[classInfos addObject:val];
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> addClassInfoReference %d -> %@", [classInfos count], val];
}

-(id)getClassInfoReference:(int)index {
	
    if (index >= classInfos.count) {
        [DebLog logY:@"ParseContext -> getClassInfoReference: (ERROR) index: %d => count: %d", index, classInfos.count];
		return nil;
    }
    
    id ref = [classInfos objectAtIndex:index];
	[DebLog log:_ON_READERS_LOG_ text:@"ParseContext -> getClassInfoReference: %d -> %@", index, ref];
	
	return ref;
}

-(int)getVersion {
	return _version;
}

@end
