//
//  Types.m
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import "Types.h"
#import "DEBUG.h"
#import <objc/runtime.h>

#define SWIFT_ON 1

@implementation Types
@synthesize swiftClassPrefix;

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own.
+(Types *)sharedInstance {
    static Types *sharedTypes;
    @synchronized(self)
    {
        if (!sharedTypes)
            sharedTypes = [[Types alloc] init];
    }
    return sharedTypes;
}

-(id)init {
    if (self = [super init]) {
        abstractMappings = [[NSMutableDictionary alloc] init];
        clientMappings = [[NSMutableDictionary alloc] init];
        serverMappings = [[NSMutableDictionary alloc] init];
        propertyMappings = [[NSMapTable<Class, NSMutableDictionary *> alloc] init];
        self.swiftClassPrefix = [Types targetName];
    }
    return self;
}

-(void)dealloc {
    
    [DebLog logN:@"DEALLOC Types"];
    
    [self.swiftClassPrefix release];
    
    [abstractMappings removeAllObjects];
    [abstractMappings release];
    
    [clientMappings removeAllObjects];
    [clientMappings release];
    
    [serverMappings removeAllObjects];
    [serverMappings release];
    
    [propertyMappings removeAllObjects];
    [propertyMappings release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(NSString *)filteredClassName:(Class)type  {
    
    NSString *typeName = type ? [NSString stringWithUTF8String:class_getName(type)] : nil;
    
#if SWIFT_ON
    if (!typeName || [typeName hasPrefix:@"Swift._"])
        return typeName;
    
    // CLIENT SWIFT CLASS ?
    
    if ([typeName rangeOfString:@"."].length) {
        
        NSArray *parts = [typeName componentsSeparatedByString:@"."];
        NSString *className = parts[parts.count-1];
        
        [DebLog logN:@"Types -> filteredClassName: [1] (<--- SWIFT CLASS --->) <%@> %@ -> %@", typeName, className, type];
        
        return className;
        
    }
    
    if ([typeName hasPrefix:@"_TtC"]) {
        
        // -----  TODO - need to implement separating process for class with digits & struct-"namespace" in classname
        
        NSArray *parts = [typeName componentsSeparatedByCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        NSString *className = parts[parts.count-1];
        NSString *mappedType = NSStringFromClass(type);
        [clientMappings setObject:type forKey:className];
        [serverMappings setObject:className forKey:mappedType];
        
        // ----------------------------------------------------------------------------------------------------------
        
        [DebLog logN:@"Types -> filteredClassName: [2] (<--- SWIFT CLASS --->) <%@> %@ -> %@ ", typeName, className, mappedType];
        
        return className;
        
    }
#endif
    
    return typeName;
}


#pragma mark -
#pragma mark Public Methods

-(void)addAbstractClassMapping:(Class)abstractType mapped:(Class)mappedType {
    
    if (!abstractType || !mappedType)
        return;
    
    [abstractMappings setObject:mappedType forClassKey:abstractType];
}

-(Class)getAbstractClassMapping:(Class)type {
    
    if (!type)
        return nil;
    
    return [abstractMappings objectForClassKey:type];
}

-(void)addClientClassMapping:(NSString *)clientClass mapped:(Class)mappedServerType {
    
    if (!clientClass || !clientClass.length || !mappedServerType)
        return;
    
    [clientMappings setObject:mappedServerType forKey:clientClass];
    [serverMappings setObject:clientClass forKey:[Types typeClassName:mappedServerType]];
}

-(Class)getServerTypeForClientClass:(NSString *)clientClass {
    
    if (!clientClass || !clientClass.length)
        return nil;
    
    return [clientMappings objectForKey:clientClass];
}

-(NSString *)getClientClassForServerType:(NSString *)serverClassName {
    return (serverClassName && serverClassName.length) ? [serverMappings objectForKey:serverClassName] : nil;
}

-(NSString *)objectMappedClassName:(id)obj {
    NSString *name = [Types objectClassName:obj];
    NSString *mapped = [__types getClientClassForServerType:name];
    return mapped?mapped:name;
}

-(NSString *)typeMappedClassName:(Class)type {
    NSString *name = [Types typeClassName:type];
    NSString *mapped = [__types getClientClassForServerType:name];
    return mapped?mapped:name;
}

-(void)addClientPropertyMappingForClass:(Class)clientClass columnName:(NSString *)columnName propertyName:(NSString *)propertyName {
    if (!clientClass || !columnName || !propertyName) {
        return;
    }
    NSMutableDictionary *propertyMappingsForClass = [propertyMappings objectForKey:[clientClass class]] ? [propertyMappings objectForKey:[clientClass class]] : [NSMutableDictionary new];
    
    [propertyMappingsForClass setObject:propertyName forKey:columnName];
    [propertyMappings setObject:propertyMappingsForClass forKey:[clientClass class]];
}

-(NSDictionary *)getPropertiesMappingForClientClass:(Class)clientClass {    
    return [propertyMappings objectForKey:[clientClass class]] ? [propertyMappings objectForKey:[clientClass class]] : [NSDictionary new];
}

// type reflecting

+(NSString *)objectClassName:(id)obj {
    return (obj) ? [Types typeClassName:[obj class]] : nil;
}

+(NSString *)typeClassName:(Class)type {
    return [__types filteredClassName:type];
}

+(NSString *)insideTypeClassName:(Class)type {
    return type ? [NSString stringWithUTF8String:class_getName(type)] : nil;
}

-(id)classInstance:(Class)type {
    
    if (!type)
        return nil;
    
    [DebLog logN:@"Types -> classInstance: (!!!!!!!!!!!!!!! CREATE !!!!!!!!!!!!!!!) %@", type];
    

    id instance = class_createInstance(type, 0);

    
    if (!instance) {
#if SWIFT_ON // try to get swift client class instance
        Class swift = [__types classByName:[NSString stringWithFormat:@"%@.%@", self.swiftClassPrefix, [Types typeClassName:type]]];
        [DebLog logN:@"Types -> classInstance: (!!!!!!!!!!!!!!! SWIFT CREATE !!!!!!!!!!!!!!!) %@", swift];
        instance = class_createInstance(swift, 0);
        if (!instance)
            return nil;
#else
        return nil;
#endif
    }
    return [[instance init] autorelease];
}

-(Class)classByName:(NSString *)className {
    Class type = objc_lookUpClass([className UTF8String]);
#if SWIFT_ON // try to get swift client class
    if (!type) {
        NSString *named = [NSString stringWithFormat:@"%@.%@", self.swiftClassPrefix, className];
        [DebLog logN:@"Types -> classByName: (!!!!!!!!!!!!!!! SWIFT CLASS !!!!!!!!!!!!!!!) %@", named];
        return objc_lookUpClass([named UTF8String]);
    }
#endif
    return type;
}

+(id)classInstanceByClassName:(NSString *)className {
    return (className) ? [__types classInstance:[__types classByName:className]] : nil;
}

+(BOOL)isAssignableFrom:(Class)type toObject:(id)obj {
    return type && obj && [type isSubclassOfClass:[obj class]];
}

+(NSArray *)propertyKeys:(id)obj {
    
    if (!obj)
        return [NSArray array];
    
    NSMutableArray *attrs = [NSMutableArray array];
    
    Class class = [obj class];
    while (class != [NSObject class]) {
        
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for(int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
            [attrs addObject:[NSString stringWithUTF8String:property_getName(property)]];
        }
        free(properties);
        
        class = [class superclass];
    }
    
    // remove iOS8 "additional" properties
    [attrs removeObject:@"hash"];
    [attrs removeObject:@"superclass"];
    [attrs removeObject:@"description"];
    [attrs removeObject:@"debugDescription"];
    
    //NSLog(@"Types -> propertyKeys: <%@> count=%lu\n%@", [obj class], (unsigned long)attrs.count, attrs);
    return [NSArray arrayWithArray:attrs];
}

+(NSArray *)propertyAttributes:(id)obj {
    
    if (!obj)
        return [NSArray array];
    
    NSMutableArray *attrs = [NSMutableArray array];
    
    Class class = [obj class];
    while (class != [NSObject class]) {
        
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for(int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
            [attrs addObject:[NSString stringWithUTF8String:property_getAttributes(property)]];
        }
        free(properties);
        
        class = [class superclass];
    }
    
    //NSLog(@"propertyAttributes: count=%d", attrs.count);
    return [NSArray arrayWithArray:attrs];
}

+(NSDictionary *)propertyKeysWithAttributes:(id)obj {
    
    if (!obj)
        return [NSDictionary dictionary];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    Class class = [obj class];
    while (class != [NSObject class]) {
        
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(class, &outCount);
        for(int i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            //fprintf(stdout, "%s %s\n", property_getName(property), property_getAttributes(property));
            NSString *key = [NSString stringWithUTF8String:property_getName(property)];
            NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(property)];
            [dict setValue:attrs forKey:key];
        }
        free(properties);
        
        class = [class superclass];
    }
    
    //NSLog(@"propertyKeysWithAttributes: count=%d", dict.count);
    return [NSDictionary dictionaryWithDictionary:dict];
}

+(NSDictionary *)propertyDictionary:(id)obj {
    //NSLog(@"!!!!!!!!!!!!!!!!!!!!!! propertyDictionary: %@", obj);
    return (obj) ? [obj dictionaryWithValuesForKeys:[Types propertyKeys:obj]] : [NSDictionary dictionary];
}


// get swift class prefix from the caller class (usually AppDelegate), item = [NSThread callStackSymbols][1];
-(void)makeSwiftClassPrefix:(NSString *)item {
    
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *items = [NSMutableArray arrayWithArray:[item componentsSeparatedByCharactersInSet:separatorSet]];
    [items removeObject:@""];
    //NSLog(@"ITEMS = %@", items);
    
    NSMutableString *prefix = [NSMutableString string];
    NSUInteger count = items.count;
    for (NSUInteger i = 1; i < count-3; i++) {
        if (i > 1) {
            [prefix appendString:@"_"];
        }
        [prefix appendString:items[i]];
    }
    // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID138
    if ([@"0123456789" rangeOfString:[prefix substringWithRange:NSMakeRange(0, 1)]].length) {
        [prefix replaceCharactersInRange:NSMakeRange(0, 1) withString:@"_"];
    }
    
    NSArray *parts = [prefix componentsSeparatedByString:@"_0x0"];
    if (parts.count > 1) {
        prefix = parts[0];
    }

    
    self.swiftClassPrefix = prefix;
    //NSLog(@"Types.swiftClassPrefix = '%@'", self.swiftClassPrefix);
}


+(NSString *)targetName {
    NSString *data = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet punctuationCharacterSet];
    [charSet addCharactersInString:@"~`$^+=|<> "];
    return [[data componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@"_"];
}

+(NSDictionary *)getInfoPlist {
    
    NSPropertyListFormat format;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    
    //NSLog(@"Types->getInfoPlist: plistPath = %@, plistXML =  %@", plistPath, plistXML);
    
    if (!plistXML) {
        return nil;
    }
    

    NSError *error = nil;
    NSDictionary *result = (NSDictionary *)[NSPropertyListSerialization propertyListWithData:plistXML
                                                                                     options:NSPropertyListMutableContainersAndLeaves
                                                                                      format:&format
                                                                                       error:&error];
    if (!result)
        NSLog(@"Error reading plist: %@, format: %ld", error, (long)format);
    
    
    //NSLog(@"Types->getInfoPlist: %@", result);
    
    return result;
}

+(id)getInfoPlist:(NSString *)key {
    NSDictionary *plist = [Types getInfoPlist];
    return (plist) ? [plist valueForKey:key] : nil;
}

// try catch functionality for swift by wrapping around Objective-C
+(void)tryblock:(void(^)(void))tryblock catchblock:(void(^)(id exception))catchblock finally:(void(^)(void))finally {
    
    @try {
        tryblock ? tryblock() : nil;
    }
    
    @catch (id exception) {
        catchblock ? catchblock(exception) : nil;
    }
    
    @finally {
        finally ? finally() : nil;
    }
}

+(void)tryblock:(void(^)(void))tryblock catchblock:(void(^)(id exception))catchblock {
    
    @try {
        tryblock ? tryblock() : nil;
    }
    
    @catch (id exception) {
        catchblock ? catchblock(exception) : nil;
    }
}

+(void)throwObjectAsException:(id)obj {
    @throw obj;
}

@end


@implementation NSDictionary (Class)

-(id)objectForClassKey:(Class)classKey {
    return [self valueForKey:[Types typeClassName:classKey]];
}

-(id)objectForObjectKey:(id)objectKey {
    return [self valueForKey:[Types objectClassName:objectKey]];
    
}

@end


@implementation NSMutableDictionary (Class)

-(void)setObject:(id)anObject forClassKey:(Class)classKey {
    [self setValue:anObject forKey:[Types typeClassName:classKey]];
}

-(void)setObject:(id)anObject forObjectKey:(id)objectKey {
    [self setValue:anObject forKey:[Types objectClassName:objectKey]];
}

@end


@implementation NSObject (AMF)

-(id)onAMFSerialize {
    [DebLog logN:@"NSObject (AMF) -> onAMFSerialize: <%@>", [self class]];
    return self;
}

// overrided method MUST return 'self' to avoid a deserialization breaking
-(id)onAMFDeserialize {
    [DebLog logN:@"NSObject (AMF) -> onAMFDeserialize: <%@>", [self class]];
    return self;
}

+(id)pastAMFDeserialize:(id)obj {
    return obj;
}

@end


@implementation NSString (Chars)

-(NSString *)firstCharToUpper {
    
    char *s = malloc([self length]+10);
    char *_str = (char *)[self UTF8String];
    strcpy(s, _str);
    s[0] = toupper(s[0]);
    NSString *result = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    free (s);
    
    return result;
}

-(NSString *)stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#define _RANDOM_MAX_LENGTH 4000

// Generates a random string of up to 4000 characters in length. Generates a random length up to 4000 if numCharacters is set to 0
+(NSString *)randomString:(int)numCharacters {
    static char const possibleChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    int len = (numCharacters > _RANDOM_MAX_LENGTH || numCharacters == 0)? (int)rand() % (_RANDOM_MAX_LENGTH) : numCharacters;
    unichar characters[len];
    for( int i=0; i < len; ++i ) {
        characters[i] = possibleChars[arc4random_uniform(sizeof(possibleChars)-1)];
    }
    return [NSString stringWithCharacters:characters length:len] ;
}

@end


@implementation NSObject (Properties)

-(Class)ofClass {
    return [self class];
}

-(BOOL)isPropertyResolved:(NSString *)name {
    return name ? (BOOL)class_getProperty([self class], [name UTF8String]) : NO;
}

-(BOOL)getPropertyIfResolved:(NSString *)name value:(id *)value {
    BOOL result = [self isPropertyResolved:name];
    (*value) = result ? [self valueForKey:name] : nil;
    return result;
}

-(BOOL)resolveProperty:(NSString *)name {
    
    Class class = [self class];
    const char *cName = [name UTF8String];
    if (!class_getProperty(class, cName))
    {
        SEL selSetter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [name firstCharToUpper]]);
        SEL selGetter = NSSelectorFromString(name);
        
        IMP setterIMP = imp_implementationWithBlock(^(id _self, id value) {
            objc_setAssociatedObject(_self, selGetter, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
        
        IMP getterIMP = imp_implementationWithBlock(^(id _self) {
            return objc_getAssociatedObject(_self, selGetter);
        });
        
        class_addProperty(class, cName, nil, 0);
        class_addMethod(class, selSetter, setterIMP, "v@:@");
        class_addMethod(class, selGetter, getterIMP, "@@:");
    }
    
    return YES;
}

-(BOOL)resolveProperty:(NSString *)name value:(id)value {
    
    if ([self resolveProperty:name]) {
        
        @try {
            [self setValue:value forKey:name];
            [DebLog logN:@"Types::NSObject(Properties) -> resolveProperty: RESOLVE PROPERTY '%@' = %@", name, value];
            return YES;
        }
        
        @catch (NSException *exception) {
            [DebLog logY:@"Types::NSObject (Properties) -> resolveProperty:value: <%@> %@ <%@> EXCEPTION = %@", [self class], name, [value class], exception];
        }
    }
    return NO;
}

-(BOOL)resolveProperties:(NSDictionary *)properties {
    
    BOOL result = YES;
    
    NSArray *props = [properties allKeys];
    for (NSString *prop in props) {
        result &= [self resolveProperty:prop value:[properties valueForKey:prop]];
    }
    
    return result;
}

-(BOOL)replaceProperty:(NSString *)name {
    
    Class class = [self class];
    const char *cName = [name UTF8String];
    if (class_getProperty(class, cName))
    {
        SEL selSetter = NSSelectorFromString([NSString stringWithFormat:@"set%@:", [name firstCharToUpper]]);
        SEL selGetter = NSSelectorFromString(name);
        
        IMP setterIMP = imp_implementationWithBlock(^(id _self, id value) {
            objc_setAssociatedObject(_self, selGetter, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
        
        IMP getterIMP = imp_implementationWithBlock(^(id _self) {
            return objc_getAssociatedObject(_self, selGetter);
        });
        
        class_replaceProperty(class, cName, nil, 0);
        class_replaceMethod(class, selSetter, setterIMP, "v@:@");
        class_replaceMethod(class, selGetter, getterIMP, "@@:");
    }
    
    return YES;
    
}

-(BOOL)replaceProperties:(NSArray *)names {
    
    BOOL result = YES;
    
    for (NSString *name in names) {
        result &= [self replaceProperty:name];
    }
    
    return result;
}

-(BOOL)replaceAllProperties {
    return [self replaceProperties:[Types propertyKeys:self]];
}

@end

