//
//  MessageWriter.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#define OLD_STANDARD_CLASSES_PROCESSING 0

#import "MessageWriter.h"
#import "DEBUG.h"
#import "ObjectWriter.h"
#import "NullWriter.h"
#import "NumberWriter.h"
#import "DateWriter.h"
#import "StringWriter.h"
#import "AnonymousObject.h"
#import "PropertyBagWriter.h"
#import "BoundPropertyBagWriter.h"
#import "ArrayWriter.h"
#import "AMFBodyWriter.h"
#import "AMFHeaderWriter.h"
#import "AMFMessageWriter.h"
#import "BodyHolderWriter.h"
#import "Body.h"
#import "MHeader.h"
#import "Request.h"
#import "BodyHolder.h"
#import "Types.h"

// 
#define NULL_WRITER @"NullWriter"
#define DEFAULT_WRITER @"DefaultWriter"

@interface MessageWriter ()
-(void)setDefaultWriters;
-(void)setFunctionalTypeWriter:(NSString *)functionName typeWriter:(id <ITypeWriter>)writer;
-(id <ITypeWriter>)getTypeWriter:(Class)type;
-(id <ITypeWriter>)getFunctionalTypeWriter:(NSString *)functionName;
-(id <ITypeWriter>)getAdditionalTypeWriter:(Class)type;
-(id <ITypeWriter>)getStandardTypeWriter:(Class)type;
-(id <ITypeWriter>)getSwiftTypeWriter:(Class)type;
@end


@implementation MessageWriter

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(MessageWriter *)sharedInstance {
	static MessageWriter *sharedMessageWriter;
	@synchronized(self)
	{
		if (!sharedMessageWriter)
			sharedMessageWriter = [MessageWriter new];
	}
	return sharedMessageWriter;
}

-(id)init {	
	if ( (self=[super init]) ) {
        writers = [NSMutableDictionary new];
		functionalWriters = [NSMutableDictionary new];
		additionalWriters = [NSMutableDictionary new];
		
		[self setDefaultWriters];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC MessageWriter"];
	
	[writers removeAllObjects];
	[writers release];
	
	[functionalWriters removeAllObjects];
	[functionalWriters release];
	
	[additionalWriters removeAllObjects];
	[additionalWriters release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(void)setDefaultWriters {
	
	[DebLog logN:@"MessageWriter -> setDefaultWriters"];
	[DebLog logN:@"MessageWriter -> setDefaultWriters: '%@','%@'", [[NSArray array] class], [[NSMutableArray array] class]];
	
	id <ITypeWriter> obj;

#if OLD_STANDARD_CLASSES_PROCESSING
    // types
    obj = [NullWriter writer];
	[writers setObject:obj forClassKey:[NSNull class]];
	//
    obj = [StringWriter writer];
	[writers setObject:obj forClassKey:[[NSString string] class]];
	[writers setObject:obj forClassKey:[[NSMutableString string] class]];
	[writers setObject:obj forClassKey:[[NSData data] class]];
	[writers setObject:obj forClassKey:[[NSMutableData data] class]];
    BinaryStream *stream = [BinaryStream streamWithAllocation:1];
	[writers setObject:obj forClassKey:[[NSData dataWithBytes:stream.buffer length:stream.size] class]];
    //
	obj = [NumberWriter writer];
	[writers setObject:obj forClassKey:[[NSNumber numberWithBool:NO] class]];
	[writers setObject:obj forClassKey:[[NSNumber numberWithInt:0] class]];
    //
    obj = [DateWriter writer];
    [writers setObject:obj forClassKey:[[NSDate date] class]];
    [writers setObject:obj forClassKey:[[NSDate dateWithTimeIntervalSince1970:1000] class]];
	
    // collections
	obj = [ArrayWriter writer];
	[writers setObject:obj forClassKey:[[NSArray array] class]];
	[writers setObject:obj forClassKey:[[NSMutableArray array] class]];
	[writers setObject:obj forClassKey:[[NSSet set] class]];
	[writers setObject:obj forClassKey:[[NSMutableSet set] class]];
    //
    obj = [BoundPropertyBagWriter writer];
	[writers setObject:obj forClassKey:[[NSDictionary dictionary] class]];
	[writers setObject:obj forClassKey:[[NSMutableDictionary dictionary] class]];
#endif
    
    // objects
    obj = [PropertyBagWriter writer];
    [writers setObject:obj forClassKey:[AnonymousObject class]];
    obj = [AMFBodyWriter writer];
	[writers setObject:obj forClassKey:[Body class]];
    obj = [AMFHeaderWriter writer];
	[writers setObject:obj forClassKey:[MHeader class]];
    obj = [AMFMessageWriter writer];
	[writers setObject:obj forClassKey:[Request class]];
    obj = [BodyHolderWriter writer];
	[writers setObject:obj forClassKey:[BodyHolder class]];
	
	// functional
	[self setFunctionalTypeWriter:NULL_WRITER typeWriter:[NullWriter writer]];
	[self setFunctionalTypeWriter:DEFAULT_WRITER typeWriter:[ObjectWriter writer]];
}

-(void)setFunctionalTypeWriter:(NSString *)functionName typeWriter:(id <ITypeWriter>)writer {
	[functionalWriters setObject:writer forKey:functionName];
}

-(id <ITypeWriter>)getTypeWriter:(Class)type {
	return [writers objectForClassKey:type];
}

-(id <ITypeWriter>)getFunctionalTypeWriter:(NSString *)functionName {
	return [functionalWriters objectForKey:functionName];
}

-(id <ITypeWriter>)getAdditionalTypeWriter:(Class)type {
	return [additionalWriters objectForClassKey:type];
}

-(id <ITypeWriter>)getStandardTypeWriter:(Class)type {
    // number?
    if ([type isSubclassOfClass:[NSNumber class]])
        return [NumberWriter writer];
    // string?
    if ([type isSubclassOfClass:[NSString class]] || [type isSubclassOfClass:[NSData class]])
        return [StringWriter writer];
    // date?
    if ([type isSubclassOfClass:[NSDate class]])
        return [DateWriter writer];
    // array?
    if ([type isSubclassOfClass:[NSArray class]] || [type isSubclassOfClass:[NSSet class]])
        return [ArrayWriter writer];
    // dictionary?
    if ([type isSubclassOfClass:[NSDictionary class]])
        return [BoundPropertyBagWriter writer];
    // null?
    if ([type isSubclassOfClass:[NSNull class]])
        return [NullWriter writer];
	// standard type is not found
	return nil;
}

// !!! OLD IMPLEMENTATION !!! - don't need if check standard class above
-(id <ITypeWriter>)getSwiftTypeWriter:(Class)type {
    
    NSString *className = [Types insideTypeClassName:type];
    // swift string?
    if ([className hasPrefix:@"Swift._NSContiguousString"])
        return [StringWriter writer];
    //swift array?
    if ([className hasPrefix:@"Swift._NSSwiftArrayImpl"])
        return [ArrayWriter writer];
    //swift dictionary?
    if ([className hasPrefix:@"_TtCSs29_NativeDictionary"])
        return [BoundPropertyBagWriter writer];
    // swift type is not found
    return nil;
}


#pragma mark -
#pragma mark Public Methods

-(void)writeObject:(id)obj format:(IProtocolFormatter *)formatter {
	id <ITypeWriter> typeWriter = [self getWriter:obj format:formatter];
	if (typeWriter) {
        [typeWriter write:obj format:formatter];
        
        [DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> writeObject: obj = %@,  typeWriter = '%@', formatter = %@", obj, typeWriter, formatter];
        [formatter.writer print:NO];
    }
}

-(void)addAdditionalTypeWriter:(Class)mappedType typeWriter:(id <ITypeWriter>)writer {
	[additionalWriters setObject:writer forClassKey:mappedType];
}

-(void)cleanAdditionalWriters {
	[additionalWriters removeAllObjects];
}

-(id <ITypeWriter>)getWriter:(id)obj format:(IProtocolFormatter *)formatter {
	
	if (obj == nil) {
        
        [DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> getWriter: (ATTENTION!) obj == nil"];
        
		return [self getFunctionalTypeWriter:NULL_WRITER];
    }
	
	Class objectType = [obj class];
	
	[DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> getWriter: (0) objectType = %@", objectType];
	
	id <ITypeWriter> writer = [formatter getCachedWriter:objectType];
	if (!writer) {
		// none of the interfaces matched a writer, perform a loocup for the object class hierarchy
		writer = [self getWriter:objectType format:formatter withInterfaces:YES];		
		
		if (!writer) {
			writer = [self getFunctionalTypeWriter:DEFAULT_WRITER];
			
			[DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> getWriter: (ATTENTION!) cannot find a writer for object, will use default writer"];
		}
		
		[formatter addCachedWriter:objectType writer:writer];
	}
	
    [DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> getWriter: (1) %@", writer];
	
	id <ITypeWriter> referenceWriter = [writer getReferenceWriter];
	if (referenceWriter) {
        [formatter setContextWriter:writer];
		writer = referenceWriter;
	}
 	
    [DebLog log:_ON_WRITERS_LOG_ text:@"MessageWriter -> getWriter: (2) %@, contextWriter: %@", writer, formatter.contextWriter];
	
	return writer;
}

-(id <ITypeWriter>)getWriter:(Class)type format:(IProtocolFormatter *)formatter withInterfaces:(BOOL)checkInterfaces {
	
	if (!type)
		return nil;
	
	id <ITypeWriter> writer = nil;
	// formatter checks for any protocol specific type bindings
	if (formatter) writer = [formatter getWriter:type];
	// check the additional lookup table owerriding main table
	if (!writer) writer = [self getAdditionalTypeWriter:type];
	// check against the main lookup table
	if (!writer) writer = [self getTypeWriter:type];
    // check standard classes
    if (!writer) writer = [self getStandardTypeWriter:type];
    
    [DebLog log:(_ON_WRITERS_LOG_) text:@"MessageWriter -> getWriter: %@ for type = %@", writer, type];
	
	return writer;
}

@end
