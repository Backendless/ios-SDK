//
//  BackendlessCache.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "BackendlessCache.h"
#import "AMFSerializer.h"
#import "BackendlessCacheData.h"
#import "BackendlessCacheKey.h"
#import "AbstractQuery.h"
#import "Invoker.h"
#import "Responder.h"
#import "DEBUG.h"
#import "Types.h"

@interface BackendlessCache()
{
    
}
+(NSString *)filePath;
-(id)responseHandler:(id)response;
-(id)responseError:(id)error;
-(void)prepareToClear:(BackendlessCacheKey *)key;
@end
@implementation BackendlessCache

+(BackendlessCache *)sharedInstance {
	static BackendlessCache *sharedBackendlessCache;
	@synchronized(self)
	{
		if (!sharedBackendlessCache)
        {
			sharedBackendlessCache = [BackendlessCache new];
            [sharedBackendlessCache loadFromDisc];
        }
	}
	return sharedBackendlessCache;
}

-(id)init
{
    self = [super init];
    if (self) { 
        _cacheData = [NSMutableDictionary new];
        _cachePolicy = [[BackendlessCachePolicy alloc] init];
        _storedType = [[NSNumber alloc] initWithInt:BackendlessCacheStoredMemory];
        [[Types sharedInstance] addClientClassMapping:@"com.backendless.services.persistence.BackendlessCollection" mapped:[BackendlessCollection class]];
    }
    return self;
}
-(void)dealloc
{
    [_storedType release];
    [_cacheData release];
    [_cachePolicy release];
    [super dealloc];
}
-(void)storedType:(BackendlessCacheStoredEnum)storedType
{
    [_storedType release];
    _storedType = [[NSNumber alloc] initWithInt:storedType];
}
+(NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/BackendlessCache"];
    return filePath;
}
-(void)saveOnDisc
{
//    dispatch_queue_t queue = dispatch_queue_create("BackendlessSaveCacheOnDisc", NULL);
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self) {
//            @autoreleasepool
//            {
//            NSLog(@"start write");
                NSMutableDictionary *notEditData = self.cacheData;
                NSArray *keyes = [notEditData allKeys];
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                
                int i = 1;
                for (BackendlessCacheKey *key in keyes)
                {
                    BackendlessCacheData *cacheData = [notEditData objectForKey:key];
                    if (cacheData.file.length > 0)
                    {
                        BackendlessCacheData *newData = [[[BackendlessCacheData alloc] initWithCache:cacheData] autorelease];
                        newData.data = nil;
                        [dictionary setValue:@[key, newData] forKey:[NSString stringWithFormat:@"%i", i]];
                    }
                    else
                        [dictionary setValue:@[key, cacheData] forKey:[NSString stringWithFormat:@"%i", i]];
                    i++;
                }
                _cacheData = dictionary;
                
                BinaryStream *stream = [AMFSerializer serializeToBytes:self];
                NSData *data = [NSData dataWithBytes:stream.buffer length:stream.size];
                [[NSFileManager defaultManager] removeItemAtPath:[BackendlessCache filePath] error:nil];
                [data writeToFile:[BackendlessCache filePath] atomically:YES];
                _cacheData = notEditData;
//            NSLog(@"end write");
                [DebLog logN:@"backendless cache saved on disc"];
//                dispatch_release(queue);
//            }
        }
    });
}
-(void)loadFromDisc
{
    @synchronized(self)
    {
        NSData *data = [NSData dataWithContentsOfFile:[BackendlessCache filePath]];
        if (data) {
            BinaryStream *stream = [BinaryStream streamWithStream:(char *)[data bytes] andSize:data.length];
            BackendlessCache *cache = [AMFSerializer deserializeFromBytes:stream];
            _cachePolicy = [cache.cachePolicy retain];
            [_cacheData release];
            [_storedType release];
            _storedType = [cache.storedType retain];
            _cacheData = [[NSMutableDictionary alloc] init];
            NSArray *data = [cache.cacheData allValues];
            for (NSArray *val in data)
            {
                BackendlessCacheData *cacheData = [val objectAtIndex:1];
                BackendlessCacheKey *key = [val objectAtIndex:0];
                
                if (!cacheData.data) {
                    [cacheData dataFromDisc];
                }
                [self addCacheObject:cacheData.data forKey:key];
            }
        }
    }
}
-(void)clearFromDisc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self)
        {
            NSArray *data = [_cacheData allValues];
            for (BackendlessCacheData *d in data) {
                [d removeFromDisc];
            }
        }
    });
}
-(void)prepareToClear:(BackendlessCacheKey *)key
{
    @synchronized(self)
    {
        BackendlessCacheData *data = [_cacheData objectForKey:key];
        [data decreasePriority];
        if (data.valPriority == 0) {
            [self clearCacheForKey:key];
        }
        else
        {
            [self performSelector:@selector(prepareToClear:) withObject:key afterDelay:data.timeToLive.integerValue];
        }
    }
}

-(void)addCacheObject:(id)object forKey:(BackendlessCacheKey *)key
{
    @synchronized(self) {
        BackendlessCacheData *data = [BackendlessCacheData new];
        
        BackendlessCachePolicy *policy = (key.query.cachePolicy) ? key.query.cachePolicy : self.cachePolicy;
        NSInteger timeToLive = policy.timeToLive.integerValue;
        if (timeToLive > 0) {
            data.timeToLive = [NSNumber numberWithInteger:timeToLive];
        }
        switch (policy.valCachePolicy) {
            case BackendlessCachePolicyIgnoreCache:
                break;
            default:
                switch (self.storedType.intValue) {
                        
                    case BackendlessCacheStoredMemory:
                        data.data = object;
                        break;
                        
                    case BackendlessCacheStoredDisc:
                        //save to disc
                        data.data = object;
                        [data saveOnDiscCompletion:^(BOOL done) {
//                            [self saveOnDisc];
                        }];
                        break;
                    default:
                        data.data = object;
                        break;
                }
                
                [_cacheData setObject:data forKey:key];
                if (timeToLive>0) {
                    [self performSelector:@selector(prepareToClear:) withObject:key afterDelay:timeToLive];
                }
                break;
        }
        [data release];
    }
}


-(void)addCacheObject:(id)object forClassName:(NSString *)className query:(AbstractQuery *)query
{
    BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
    [self addCacheObject:object forKey:key];
}
-(BOOL)hasResultForClassName:(NSString *)className query:(id)query
{
    @synchronized(self)
    {
        BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
        if ([_cacheData objectForKey:key]) {
            return YES;
        }
        return NO;
    }
}
-(id)objectForClassName:(NSString *)className query:(id)query
{
    BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
    return [self objectForCacheKey:key];
}
-(id)objectForCacheKey:(BackendlessCacheKey *)key
{
    @synchronized(self)
    {
        BackendlessCacheData *data = [_cacheData objectForKey:key];
        if (data) {
            [data increasePriority];
            return data.data;
        }
        return nil;
    }
}
-(void)clearCacheForClassName:(NSString *)className query:(id)query
{
    @synchronized(self) {
        BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
        [self clearCacheForKey:key];
    }
}
-(void)clearCacheForKey:(BackendlessCacheKey *)key
{
    @synchronized(self)
    {
        [[_cacheData objectForKey:key] remove];
        [_cacheData removeObjectForKey:key];
    }
}
-(void)clearAllCache
{
    @synchronized(self)
    {
        NSArray *data = [_cacheData allValues];
        for (BackendlessCacheData *d in data) {
            [d remove];
        }
        [_cacheData removeAllObjects];
    }
}

#pragma mark - invoker methods

-(id)invokeSync:(NSString *)name method:(NSString *)methodName args:(NSArray *)args
{
    AbstractQuery *query = [args objectAtIndex:3];
    NSString *className = [args objectAtIndex:2];
    BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
    BackendlessCachePolicy *policy = (query.cachePolicy)?query.cachePolicy:_cachePolicy;
    
    switch (policy.valCachePolicy) {
        case BackendlessCachePolicyIgnoreCache:
            return [invoker invokeSync:name method:methodName args:args];
        case BackendlessCachePolicyCacheOnly:
            return [self objectForCacheKey:key];
        case BackendlessCachePolicyRemoteDataOnly:
        {
            id data = [invoker invokeSync:name method:methodName args:args];
            if (![data isKindOfClass:[Fault class]]) {
                [self addCacheObject:data forKey:key];
            }
            return data;
        }
        case BackendlessCachePolicyFromCacheOrRemote:
        {
            id data = [self objectForCacheKey:key];
            if (!data)
            {
                data = [invoker invokeSync:name method:methodName args:args];
                if (![data isKindOfClass:[Fault class]]) {
                    [self addCacheObject:data forKey:key];
                }
            }
            return data;
        }
        case BackendlessCachePolicyFromCacheAndRemote:
            break;
        case BackendlessCachePolicyFromRemoteOrCache:
        {
            id data = [invoker invokeSync:name method:methodName args:args];
            if (![data isKindOfClass:[Fault class]]) {
                [self addCacheObject:data forKey:key];
            }
            else
            {
                data = [self objectForCacheKey:key];
            }
            return data;
        }
        default:
            break;
    }
    return nil;
}
-(void)invokeAsync:(NSString *)name method:(NSString *)methodName args:(NSArray *)args responder:(Responder *)responder
{
    Responder *cacheResponder = [Responder responder:self selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(responseError:)];
    cacheResponder.chained = responder;
    AbstractQuery *query = [args objectAtIndex:3];
    NSString *className = [args objectAtIndex:2];
    BackendlessCacheKey *key = [BackendlessCacheKey cacheKeyWithClassName:className query:query];
    BackendlessCachePolicy *policy = (query.cachePolicy)?query.cachePolicy:_cachePolicy;
    cacheResponder.context = key;
    switch (policy.valCachePolicy) {
        case BackendlessCachePolicyIgnoreCache:
            [invoker invokeAsync:name method:methodName args:args responder:responder];
            return;
        case BackendlessCachePolicyCacheOnly:
            [responder responseHandler:[self objectForCacheKey:key]];
            break;
        case BackendlessCachePolicyRemoteDataOnly:
            [invoker invokeAsync:name method:methodName args:args responder:cacheResponder];
            return;
        case BackendlessCachePolicyFromCacheOrRemote:
        {
            id data = [self objectForCacheKey:key];
            if (!data) {
                [invoker invokeAsync:name method:methodName args:args responder:cacheResponder];
            }
            else
            {
                [responder responseHandler:data];
            }
            return;
        }
            
        case BackendlessCachePolicyFromCacheAndRemote:
        {
            id data = [self objectForCacheKey:key];
            if (data) {
                [responder responseHandler:data];
            }
            [invoker invokeAsync:name method:methodName args:args responder:cacheResponder];
            return;
        }
            
        case BackendlessCachePolicyFromRemoteOrCache:
            [invoker invokeAsync:name method:methodName args:args responder:cacheResponder];
            return;
        default:
            break;
    }
}

#pragma mark - Responder
-(id)responseHandler:(ResponseContext *)response
{
    BackendlessCacheKey *key = response.context;
    id data = response.response;
    BackendlessCachePolicy *policy = key.query.cachePolicy?key.query.cachePolicy:_cachePolicy;
    switch (policy.valCachePolicy) {
        case BackendlessCachePolicyIgnoreCache:
            break;
        case BackendlessCachePolicyCacheOnly:
            break;
        case BackendlessCachePolicyRemoteDataOnly:
            [self addCacheObject:data forKey:key];
            break;
        case BackendlessCachePolicyFromCacheOrRemote:
            [self addCacheObject:data forKey:key];
            break;
        case BackendlessCachePolicyFromCacheAndRemote:
            [self addCacheObject:data forKey:key];
            break;
        case BackendlessCachePolicyFromRemoteOrCache:
            [self addCacheObject:data forKey:key];
            break;
        default:
            break;
    }
    return response.response;
}
-(id)responseError:(Fault *)error
{
    Responder *responder = error.context;
    id val = error.context;
    BackendlessCacheKey *key = nil;
    if ([val isKindOfClass:[Responder class]]) {
        key = ((Responder*) error.context).context;
    }
    else
    {
        key = error.context;
    }
    BackendlessCachePolicy *policy = (key.query.cachePolicy)?key.query.cachePolicy:_cachePolicy;
    switch (policy.valCachePolicy) {
        case BackendlessCachePolicyIgnoreCache:
            break;
        case BackendlessCachePolicyCacheOnly:
            break;
        case BackendlessCachePolicyRemoteDataOnly:
            break;
        case BackendlessCachePolicyFromCacheOrRemote:
            break;
        case BackendlessCachePolicyFromCacheAndRemote:
            break;
        case BackendlessCachePolicyFromRemoteOrCache:
        {
            id data = [self objectForCacheKey:key];
            if (data) {
                Responder *chain = responder.chained;
                [chain responseHandler:data];
                responder.chained = nil;
                return nil;
            }
        }
            break;
        default:
            break;
    }
    return error;
}
@end
