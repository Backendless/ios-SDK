//
//  ClientSharedObject.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "ClientSharedObject.h"
#import "DEBUG.h"
#import "ISharedObjectMessage.h"
#import "SharedObjectEvent.h"


@implementation ClientSharedObject
@synthesize delegate, owner;

-(id)initWithName:(NSString *)_name persistent:(BOOL)_persistent {	
	if( (self=[super initWithName:_name path:nil persistent:_persistent]) ) {
        owner = nil;
        initialSyncReceived = NO;
        persistentSO = persistent;
	}
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ClientSharedObject"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(id <ISharedObjectMessage>)singleEventMessage:(SharedObjectEventType)type {
    
    SharedObjectMessage *msg = [[[SharedObjectMessage alloc] 
                                 initWithName:name version:0 persistent:[self isPersistentObject]] autorelease];
    [msg addEvent:[[[SharedObjectEvent alloc] initWithType:type withKey:nil andValue:nil] autorelease]];
    
    return msg;
}

-(void)notifyModified {
    
#if 1
    [self updateVersion];
#endif
    
    SharedObjectMessage *syncOwner = [[[SharedObjectMessage alloc] 
                                       initWithName:name version:version persistent:[self isPersistentObject]] autorelease];
    [syncOwner addEvents:[ownerMessage getEvents]];
    [ownerMessage clear];
    
    if ([delegate respondsToSelector:@selector(makeUpdateMessage:)])
        [delegate makeUpdateMessage:syncOwner];
}

#pragma mark -
#pragma mark Public Methods

-(void)updateMessage:(id <ISharedObjectMessage>)message {  
    
    if ([delegate respondsToSelector:@selector(makeUpdateMessage:)])
        [delegate makeUpdateMessage:message];
}

#pragma mark -
#pragma mark IClientSharedObject Methods

-(BOOL)isConnected {
    return initialSyncReceived;
}

-(void)connect {
    
    if ([self isConnected])
        return;
    
    [self updateMessage:[self singleEventMessage:SERVER_CONNECT]];
}

-(void)disconnect {
    
    if (![self isConnected]) 
        return;
    
    [self updateMessage:[self singleEventMessage:SERVER_DISCONNECT]];   
    initialSyncReceived = NO;
    
    if ([owner respondsToSelector:@selector(onSharedObjectDisconnect:)])
        [owner onSharedObjectDisconnect:self];
}

-(void)sendMessage:(NSString *)handler arguments:(NSArray *)arguments {
	[ownerMessage addEvent:SERVER_SEND_MESSAGE withKey:handler andValue:arguments];
	[self notifyModified];
}

-(BOOL)clear {
	[self removeAttributes];
	return YES;
}

-(void)close {
	[self removeAttributes];
	[ownerMessage clear];
}

#pragma mark -
#pragma mark IEventDispatcher Methods

-(void)dispatchEvent:(id <IEvent>)e {
    
    //[DebLog logY:@"ClientSharedObject -> dispatchEvent: e.type = %d", (int)[e getType]];
    
    if (([e getType] != SHARED_OBJECT) || !([(id <NSObject>)e conformsToProtocol:@protocol(ISharedObjectMessage)])) 
        return;
    
    id <ISharedObjectMessage> msg = (id <ISharedObjectMessage>)e;
    NSArray *events = [msg getEvents];
#if 1
    version = [msg getVersion];
#endif
    
    [DebLog log:@"ClientSharedObject -> dispatchEvent: msg.name = %@, msg.type = %d, msg.events.count = %d", [msg getName], (int)[msg getType], events.count];
    
    for (id <ISharedObjectEvent> evt in events) {
        
        //[DebLog logY:@"ClientSharedObject -> dispatchEvent: evt.type = %d", (int)[evt getType]];
        
        switch ([evt getType]) {
            
            case CLIENT_STATUS: {
                
                [DebLog log:@"ClientSharedObject -> dispatchEvent: (CLIENT_STATUS) '%@':'%@')", [evt getKey], [evt getValue]];
                
                break;
            }
                
            case CLIENT_INITIAL_DATA: {
                initialSyncReceived = YES;
                
                [DebLog logN:@"ClientSharedObject -> dispatchEvent: (CLIENT_INITIAL_DATA)"];
               
                if ([owner respondsToSelector:@selector(onSharedObjectConnect:)])
                    [owner onSharedObjectConnect:self];
                
                break;
            }
            
            case CLIENT_CLEAR_DATA: {
                
                [DebLog logN:@"ClientSharedObject -> dispatchEvent: (CLIENT_CLEAR_DATA)"];
                
                [attributes removeAllObjects];
                
                if ([owner respondsToSelector:@selector(onSharedObjectClear:)])
                    [owner onSharedObjectClear:self];

                break;
            }
            
            case CLIENT_DELETE_DATA:
            case CLIENT_DELETE_ATTRIBUTE: {
                [attributes removeObjectForKey:[evt getKey]];
                
                if ([owner respondsToSelector:@selector(onSharedObjectDelete:withKey:)])
                    [owner onSharedObjectDelete:self withKey:[evt getKey]];
                
               break;
            }
                
            case CLIENT_SEND_MESSAGE: {
                
                if ([owner respondsToSelector:@selector(onSharedObjectSend:withMethod:andParams:)])
                    [owner onSharedObjectSend:self withMethod:[evt getKey] andParams:[evt getValue]];
                
                break;
            }
                
            case CLIENT_UPDATE_DATA: {
                
                NSDictionary *newValues = [evt getValue];
                NSArray *keys = [newValues allKeys];
                
                [DebLog logN:@"ClientSharedObject->dispatchEvent(CLIENT_UPDATE_DATA):%@", newValues];
                
                for (NSString *key in keys) 
                    [attributes setValue:[newValues valueForKey:key] forKey:key];
                
                if ([owner respondsToSelector:@selector(onSharedObjectUpdate:withDictionary:)])
                    [owner onSharedObjectUpdate:self withDictionary:newValues];
               
                break;
            }
                
            case CLIENT_UPDATE_ATTRIBUTE: {
                
                NSString *key = [evt getKey];
                NSArray *data = [evt getValue];
                id value = nil;
                
                if (data && (data.count == 1)) {
                    value = [data objectAtIndex:0];
                    [attributes setValue:value forKey:key];
                }
                
                if (!value)
                    value = [attributes valueForKey:key];
                
                [DebLog logN:@"ClientSharedObject->dispatchEvent(CLIENT_UPDATE_ATTRIBUTE):%@ = %@ <%@>", key, value, [value class]];
                 
                if ([owner respondsToSelector:@selector(onSharedObjectUpdate:withKey:andValue:)])
                    [owner onSharedObjectUpdate:self withKey:key andValue:value];
                
                break;
            }
            
            default: 
                break;
        }
    }
}

#pragma mark -
#pragma mark IAttributeStore Methods

-(id)getAttribute:(NSString *)attrName object:(id)defaultValue {
	
	if (!attrName)
		return nil;
	
	id attr = [self getAttribute:attrName];

    [DebLog logN:@"ClientSharedObject->getAttribute: attr=%@", attr];
	
    if (attr)
        return attr;
    
    [DebLog logN:@"ClientSharedObject->getAttribute - set: %@ = %@", attrName, defaultValue];
    
    [self setAttribute:attrName object:defaultValue];
    
    return defaultValue;
}

-(BOOL)setAttribute:(NSString *)attrName object:(id)value {	
    // sync if the attribute changed, if value == null - removes the attribute
    if (value) {
        [ownerMessage addEvent:SERVER_SET_ATTRIBUTE withKey:attrName andValue:value];  
        [attributes setValue:value forKey:attrName]; // ??????????? need be verified - why it isn't in original C# code
    }
    else
        [ownerMessage addEvent:SERVER_DELETE_ATTRIBUTE withKey:attrName andValue:nil];
    [self notifyModified];
	return YES;
}

-(void)setAttributes:(NSDictionary *)values {
	
	if (!values)
		return;
	
	NSArray *keys = [values allKeys];
	for (NSString *key in keys) {
        id value = [values valueForKey:key];
        if (value) {
            [ownerMessage addEvent:SERVER_SET_ATTRIBUTE withKey:key andValue:value]; 
            [attributes setValue:value forKey:key]; // ??????????? need be verified - why it isn't in original C# code
        }
        else
            [ownerMessage addEvent:SERVER_DELETE_ATTRIBUTE withKey:key andValue:nil];
    }
	[self notifyModified];	
}

-(void)setAttributeStore:(id <IAttributeStore>)values {
	
	if (!values)
		return;
	
	[self setAttributes:[values getAttributes]];
}

-(BOOL)removeAttribute:(NSString *)attrName {	
	[ownerMessage addEvent:SERVER_DELETE_ATTRIBUTE withKey:attrName andValue:nil];
    [self notifyModified];
	return YES;
}

-(void)removeAttributes {	
	NSArray *names = [self getAttributeNames];
	for (NSString *key in names) 
		[ownerMessage addEvent:SERVER_DELETE_ATTRIBUTE withKey:key andValue:nil];	
	[self notifyModified];	
}

//

-(NSArray *)getAttributeNames {
	
	return [attributes allKeys];
}

-(BOOL)hasAttribute:(NSString *)_name {
	
	if (!_name)
		return NO;
	
	return ([self getAttribute:_name] != nil);
}

-(NSDictionary *)getAttributes {
	
	return attributes;
}

-(id)getAttribute:(NSString *)_name {
	return (_name) ? [attributes valueForKey:_name] : nil;
}


@end
