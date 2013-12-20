//
//  BackendlessCacheKey.m
//  backendlessAPI
//
//  Created by Yury Yaschenko on 8/12/13.
//  Copyright (c) 2013 BACKENDLESS.COM. All rights reserved.
//

#import "BackendlessCacheKey.h"
@interface BackendlessCacheKey()
@end
@implementation BackendlessCacheKey
-(BackendlessCacheKey *)initWithClass:(Class)_class query:(id)query
{
    self = [super init];
    if (self) {
        _className = NSStringFromClass(_class);
        _query = [query retain];
    }
    return self;
}
-(BackendlessCacheKey *)initWithClassName:(NSString *)className query:(id)query
{
    self = [super init];
    if (self) {
        _className = [className retain];
        _query = [query retain];
    }
    return self;
}
-(void)dealloc
{
    [_className release];
    [_query release];
    [super dealloc];
}
-(NSUInteger)hash
{
    return [_className hash];
}
-(BOOL)isEqual:(BackendlessCacheKey *)object
{
    if (![_className isEqualToString:object.className]) {
        return NO;
    }
    NSLog(@"%@", [_query class]);
    if (![_query isEqualToQuery:object.query]) {
        return NO;
    }
    return YES;
}

+(BackendlessCacheKey *)cacheKeyWithClass:(Class)_class query:(id)query
{
    return [[[BackendlessCacheKey alloc] initWithClass:_class query:query] autorelease];
}
+(BackendlessCacheKey *)cacheKeyWithClassName:(NSString *)className query:(id)query
{
    return [[[BackendlessCacheKey alloc] initWithClassName:className query:query] autorelease];
}

-(id)copyWithZone:(NSZone *)zone
{
    return [self retain];
}

@end
