//
//  SharedObject.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttributeStore.h"
#import "IPersistable.h"
#import "IPersistenceStore.h"
#import "SharedObjectMessage.h"

/**
 * Represents shared object on server-side. Shared Objects in Flash are like cookies that are stored
 * on client side. In Red5 and Flash Media Server there's one more special type of SOs : remote Shared Objects.
 *
 * These are shared by multiple clients and synchronized between them automatically on each data change. This is done
 * asynchronously, used as events handling and is widely used in multiplayer Flash online games.
 *
 * Shared object can be persistent or transient. The difference is that first are saved to the disk and can be
 * accessed later on next connection, transient objects are not saved and get lost each time they last client
 * disconnects from it.
 *
 * Shared Objects has name identifiers and path on server's HD (if persistent). On deeper level server-side
 * Shared Object in this implementation actually uses IPersistenceStore to delegate all (de)serialization work.
 *
 * SOs store data as simple map, that is, "name-value" pairs. Each value in turn can be complex object or map.
 */

@class FlashorbBinaryReader;

@interface SharedObject : AttributeStore <IPersistable> {	
    /**
	 * Shared Object name (identifier)
	 */
	NSString	*name;
	
	/**
	 * SO path
	 */
	NSString	*path;
	
	/**
	 * true if the SharedObject was stored by the persistence framework (NOT in database,
	 * just plain serialization to the disk) and can be used later on reconnection
	 */	
	BOOL	persistent;
	
	/**
	 * true if the client / server created the SO to be persistent
	 */
	BOOL	persistentSO;
	
	/**
	 * Object that is delegated with all storage work for persistent SOs
	 */
	id <IPersistenceStore>	storage;
	
	/**
	 * Version. Used on synchronization purposes.
	 */
	int		version;
	
	/**
	 * Has changes? flag
	 */
	BOOL	modified;
	
	/**
	 * Last modified timestamp
	 */
	long	lastModified;
	
	/**
	 * Owner event
	 */
	SharedObjectMessage	*ownerMessage;
}

-(id)initWithStream:(FlashorbBinaryReader *)input;
-(id)initWithName:(NSString *)_name path:(NSString *)_path persistent:(BOOL)_persistent;
-(id)initWithName:(NSString *)_name path:(NSString *)_path persistent:(BOOL)_persistent storage:(id <IPersistenceStore>)_storage;

-(BOOL)isPersistentObject;
-(NSDictionary *)getData;
-(int)getVersion;
-(void)updateVersion;
@end
