//
//  BackendlessQueryFactory.m
//  backendlessAPI
//
//  Created by Vyacheslav Vdovichenko on 9/14/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import "BackendlessQueryFactory.h"
#import "BackendlessQuery.h"

@implementation BackendlessQueryFactory

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(BackendlessQueryFactory *)sharedInstance {
	static BackendlessQueryFactory *sharedBackendlessQueryFactory;
	@synchronized(self)
	{
		if (!sharedBackendlessQueryFactory)
			sharedBackendlessQueryFactory = [[BackendlessQueryFactory alloc] init];
	}
	return sharedBackendlessQueryFactory;
}

-(id)init {
	if ( (self=[super init]) ) {
        query = [BackendlessQuery new];
	}
	
	return self;
}

-(void)dealloc {
    
    [query release];
		
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(BackendlessQuery *)getQuery:(int)offset pageSize:(int)pageSize {
    
    [query setPageSize:pageSize];
    [query setOffset:offset];
    
    return query;
}

@end
