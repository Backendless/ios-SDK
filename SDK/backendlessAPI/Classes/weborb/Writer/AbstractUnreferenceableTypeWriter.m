//
//  AbstractUnreferenceableTypeWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "AbstractUnreferenceableTypeWriter.h"
#import "IProtocolFormatter.h"

@implementation AbstractUnreferenceableTypeWriter

#pragma mark -
#pragma mark Public Methods

+(id)writer {
	return [[AbstractUnreferenceableTypeWriter new] autorelease];
}

-(void)write:(id)obj format:(IProtocolFormatter *)formatter {
}

-(id <ITypeWriter>)getReferenceWriter {
	return nil;
}

@end
