//
//  V3ObjectReader.m
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "V3ObjectReader.h"
#import "DEBUG.h"
#import "AnonymousObject.h"
#import "NamedObject.h"
#import "ArrayType.h"
#import "ReaderUtils.h"
#import "RequestParser.h"
#import "Types.h"



@implementation V3ObjectReader

+(id)typeReader {
	return [[[V3ObjectReader alloc] init] autorelease];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC V3ObjectReader"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Private Methods

-(ClassInfo *)getClassInfo:(int)refId reader:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    if ((refId & 0x3) == 1) {
        refId = refId >> 2;
        ClassInfo *ref = (ClassInfo *)[parseContext getClassInfoReference:refId];
        [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> getClassInfo: refId=%d -> %@", refId, ref];
        return ref;
    }
    
	ClassInfo *classInfo = [[[ClassInfo alloc] init] autorelease];
    classInfo.externalizable = ((refId & 0x4) == 4);
    classInfo.looseProps = ((refId & 0x8) == 8);
    classInfo.className = [ReaderUtils readString:reader context:parseContext];
    int propsCount = refId >> 4;
    
    for (int i = 0; i < propsCount; i++) {
        [classInfo addProperty:[ReaderUtils readString:reader context:parseContext]];
    }
    
    [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> getClassInfo: %@", classInfo];
    
    [parseContext addClassInfoReference:classInfo];    
    return classInfo;
}

#pragma mark -
#pragma mark ITypeReader Methods

-(id <IAdaptingType>)read:(FlashorbBinaryReader *)reader context:(ParseContext *)parseContext {
    
    int refId = [reader readVarInteger];
    if ((refId & 0x1) == 0) {
        refId = refId >> 1;
        id <IAdaptingType> ref = [parseContext getReference:refId];
        [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> read: (+++++ REFERENCE) refId=%d -> %@", refId, ref];
        return ref;
    }
    
    ClassInfo *classInfo = [self getClassInfo:refId reader:reader context:parseContext];
    if (!classInfo)
        return nil;

#if 1 // log mapped type
    Class mappedType = [[Types sharedInstance] getServerTypeForClientClass:classInfo.className];
    [DebLog log:_ON_READERS_LOG_ text:@" ***** V3ObjectReader -> read: mappedType = '%@' -> className = '%@'\n%@ [count=%d]", mappedType, classInfo.className, classInfo.props, [classInfo getPropertyCount]];
#endif
    
    if (classInfo.externalizable) {
       
        // TODO: need to implement Util.IExternalizable, Util.ObjectFactories & Reader.CacheableAdaptingTypeWriter, then porting the below code
        
        return nil;
    }
    else {
        
        NSMutableDictionary *props = [NSMutableDictionary dictionary];
        AnonymousObject *anonObj = [AnonymousObject objectType:props];
        id <IAdaptingType> returnValue = anonObj;
        
        if (classInfo.className && (classInfo.className.length > 0))
            returnValue = [NamedObject objectType:classInfo.className withObject:anonObj];
        
        [parseContext addReference:returnValue];
        int propCount = [classInfo getPropertyCount];
        
        for (int i = 0; i < propCount; i++) {
            
            NSString *propName = [classInfo getProperty:i];
            if (!propName || !propName.length) {
                [DebLog logY:@"V3ObjectReader -> read: ERROR (1) - propName is not exist"];
                break;
            }
            
            id obj = [RequestParser readData:reader context:parseContext];
            if (!obj) obj = [NSNull null];
            [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> read: (1) { '%@':%@ <%@> }", propName, obj, [obj class]];
            [props setObject:obj forKey:propName];
       }
        
        if (classInfo.looseProps) {
            while (YES) {                
                NSString *propName = [ReaderUtils readString:reader context:parseContext];
                if (!propName || !propName.length) {
                    [DebLog logY:@"V3ObjectReader -> read: ERROR (2) - propName is not exist"];
                    break;
                }
                
                id obj = [RequestParser readData:reader context:parseContext];
                if (!obj) obj = [NSNull null];
                [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> read: (2) { '%@':%@ <%@> }", propName, obj, [obj class]];
                [props setObject:obj forKey:propName];
            }
        }
        
#if 0 // ____________________ PROPERTIES CORRECTION _________________________________________
        //[props removeObjectForKey:@"rootCause"];
        //[props removeObjectForKey:@"cause"];
        //[props removeObjectForKey:@"stackTrace"];
#endif // ___________________________________________________________________________________
        
        [DebLog log:_ON_READERS_LOG_ text:@"V3ObjectReader -> read: type=%@ propCount=%d\nprops=%@", [returnValue class], propCount, props];
        
        return returnValue;
    }
}

@end


@implementation ClassInfo
@synthesize looseProps, className, externalizable, props;

-(id)init {
	if( (self=[super init]) ) {
        looseProps = NO;
        className = nil;
        externalizable = NO;
        props = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ClassInfo"];
	
    [props removeAllObjects];
    [props release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

-(void)addProperty:(NSString *)propName {
    [props addObject:propName];
}

-(int)getPropertyCount {
    return props.count;
}

-(NSString *)getProperty:(int)index {
    return [props objectAtIndex:index];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<ClassInfo> className='%@', props=\n%@", self.className, self.props];
}

@end
