//
//  SharedObject.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "WeborbSharedObject.h"
#import "DEBUG.h"
#import "SharedObjectEvent.h"
#import "WebORBSerializer.h"
#import "WebORBDeserializer.h"

@interface WeborbSharedObject ()
-(void)defaultInitialize;
//-(void)notifyModified;
@end;


@implementation WeborbSharedObject

-(id)init {	
	if( (self=[super init]) ) {
		[self defaultInitialize];
		ownerMessage = [[SharedObjectMessage alloc] initWithSource:nil name:nil version:-1 persistent:NO];
	}
	return self;
}

-(id)initWithStream:(FlashorbBinaryReader *)input {	
	if( (self=[super init]) ) {
		[self defaultInitialize];
		ownerMessage = [[SharedObjectMessage alloc] initWithSource:nil name:nil version:-1 persistent:NO];
        [self deserialize:input];
	}
	return self;
}

-(id)initWithName:(NSString *)_name path:(NSString *)_path persistent:(BOOL)_persistent {	
	if( (self=[super init]) ) {
		[self defaultInitialize];
		name = [_name retain];
		path = [_path retain];
		persistent = _persistent;
		ownerMessage = [[SharedObjectMessage alloc] initWithSource:nil name:name version:0 persistent:persistent];
	}
	return self;
}

-(id)initWithName:(NSString *)_name path:(NSString *)_path persistent:(BOOL)_persistent storage:(id <IPersistenceStore>)_storage {	
	if( (self=[super init]) ) {
		[self defaultInitialize];
        name = [_name retain];
        path = [_path retain];
		persistent = _persistent;
		[self setStore:_storage];
		ownerMessage = [[SharedObjectMessage alloc] initWithSource:nil name:name version:0 persistent:persistent];
	}
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC SharedObject"];
    
    [name release];
    [path release];
    [ownerMessage release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(void)defaultInitialize {
	name = nil;
	path = nil;
	persistent = NO;
	persistentSO = NO;
	storage = nil;
	version = 0;
	modified = NO;
	lastModified = -1;
	ownerMessage = nil;
}


#pragma mark -
#pragma mark Public Methods

-(BOOL)isPersistentObject {
	return persistentSO;
}

-(NSDictionary *)getData {
	return [self getAttributes];
}

-(int)getVersion {
	return version;
}

-(void)updateVersion {
	version += 1;
}

#pragma mark -
#pragma mark IPersistable Methods

-(BOOL)isPersistent {
	return persistent;
}

-(void)setPersistent:(BOOL)_persistent {
	persistent = _persistent;
}

-(NSString *)getName {
	return name;
}

-(void)setName:(NSString *)_name {
	// Shared objects don't support setting of their names
}

-(NSString *)getType {
	return @"SharedObject";
}

-(NSString *)getPath {
	return path;
}

-(void)setPath:(NSString *)_path {
	path = _path;
}

-(long)getLastModified {
	return lastModified;
}

-(id <IPersistenceStore>)getStore {
	return storage;
}

-(void)setStore:(id <IPersistenceStore>)store {
	storage = store;
}

-(void)serialize:(FlashorbBinaryWriter *)output {
    WebORBSerializer *serializer = [WebORBSerializer writer:output];
    [serializer serialize:[self getName]];
    [serializer serialize:[self getAttributes]];
}

-(void)deserialize:(FlashorbBinaryReader *)input {
    WebORBDeserializer *deserializer = [WebORBDeserializer reader:input];
    name = (NSString *)[deserializer deserialize];
    persistentSO = persistent = YES;
    NSDictionary *dict = (NSDictionary *)[deserializer deserialize];

    NSArray *names = [dict allKeys];
    [super removeAttributes];
    for (NSString *_name in names)
        [self setAttribute:_name object:[dict valueForKey:_name]];
    
    [ownerMessage setName:name];
    [ownerMessage setIsPersistent:YES];    
}

@end
