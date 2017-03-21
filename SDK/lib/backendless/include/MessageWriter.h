//
//  MessageWriter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"
#import "IProtocolFormatter.h"

@interface MessageWriter : NSObject {
	NSMutableDictionary	*writers;
	NSMutableDictionary	*functionalWriters;
	NSMutableDictionary	*additionalWriters;
}

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(MessageWriter *)sharedInstance;
//
-(void)writeObject:(id)obj format:(IProtocolFormatter *)formatter;
-(void)addAdditionalTypeWriter:(Class)mappedType typeWriter:(id <ITypeWriter>)writer;
-(void)cleanAdditionalWriters;
-(id <ITypeWriter>)getStandardTypeWriter:(Class)type;
-(id <ITypeWriter>)getWriter:(id)obj format:(IProtocolFormatter *)formatter;
-(id <ITypeWriter>)getWriter:(Class)type format:(IProtocolFormatter *)formatter withInterfaces:(BOOL)checkInterfaces;
@end
