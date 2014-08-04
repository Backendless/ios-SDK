//
//  AtomicOperation.m
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

#import "AtomicCounters.h"
#import "Backendless.h"
#import "Invoker.h"
#import "AtomicCountersFactory.h"

#define FAULT_NO_NAME [Fault fault:@"Name is not valid" faultCode:@"0000"]

// SERVICE NAME
static NSString *SERVER_ATOMIC_OPERATION_SERVICE_PATH = @"com.backendless.services.redis.AtomicOperationService";
// METHOD NAMES
static NSString *METHOD_GET = @"get";
static NSString *METHOD_GET_AND_INCREMENT = @"getAndIncrement";
static NSString *METHOD_INCREMENT_AND_GET = @"incrementAndGet";
static NSString *METHOD_GET_AND_DECREMENT = @"getAndDEcrement";
static NSString *METHOD_DECREMENT_AND_GET = @"decrementAndGet";
static NSString *METHOD_ADD_AND_GET = @"addAndGet";
static NSString *METHOD_GET_AND_ADD = @"getAndAdd";
static NSString *METHOD_COMPARE_AND_SET = @"compareAndSet";

@implementation AtomicCounters

-(id)init {
	if ( (self=[super init]) ) {
        
	}
	
	return self;
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC AtomicCounters"];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public Methods

// sync methods with fault option

-(NSNumber *)get:(NSString *)name fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)getAndIncrement:(NSString *)name fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_INCREMENT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)incrementAndGet:(NSString *)name fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_INCREMENT_AND_GET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)getAndDecrement:(NSString *)name fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_DECREMENT args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)decrementAndGet:(NSString *)name fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_DECREMENT_AND_GET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)addAndGet:(NSString *)name value:(long)value fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:value]];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_ADD_AND_GET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)getAndAdd:(NSString *)name value:(long)value fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:value]];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_ADD args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

-(NSNumber *)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated fault:(Fault **)fault {
    
    if (!name) {
        if (fault) {
            (*fault) = [backendless throwFault:FAULT_NO_NAME];
        }
        return nil;
    }
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:expected], [NSNumber numberWithLong:updated]];
    id result = [invoker invokeSync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_COMPARE_AND_SET args:args];
    if ([result isKindOfClass:[Fault class]]) {
        if (fault) {
            (*fault) = result;
        }
        return nil;
    }
    
    return result;
}

// async methods with responder

-(void)get:(NSString *)name responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET args:args responder:responder];
}

-(void)getAndIncrement:(NSString *)name responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_INCREMENT args:args responder:responder];
}

-(void)incrementAndGet:(NSString *)name responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_INCREMENT_AND_GET args:args responder:responder];
}

-(void)getAndDecrement:(NSString *)name responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_DECREMENT args:args responder:responder];
}

-(void)decrementAndGet:(NSString *)name responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_DECREMENT_AND_GET args:args responder:responder];
}

-(void)addAndGet:(NSString *)name value:(long)value responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:value]];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_ADD_AND_GET args:args responder:responder];
}

-(void)getAndAdd:(NSString *)name value:(long)value responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:value]];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_GET_AND_ADD args:args responder:responder];
}

-(void)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated responder:(id<IResponder>)responder {
    
    if (!name)
        return [responder errorHandler:FAULT_NO_NAME];
    
    NSArray *args = @[backendless.appID, backendless.versionNum, name, [NSNumber numberWithLong:expected], [NSNumber numberWithLong:updated]];
    [invoker invokeAsync:SERVER_ATOMIC_OPERATION_SERVICE_PATH method:METHOD_COMPARE_AND_SET args:args responder:responder];
}

// async methods with block-based callback

-(void)get:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self get:name responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getAndIncrement:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self getAndIncrement:name responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)incrementAndGet:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self incrementAndGet:name responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getAndDecrement:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self getAndDecrement:name responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)decrementAndGet:(NSString *)name response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self decrementAndGet:name responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)addAndGet:(NSString *)name value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self addAndGet:name value:value responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)getAndAdd:(NSString *)name value:(long)value response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {    
    [self getAndAdd:name value:value responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

-(void)compareAndSet:(NSString *)name expected:(long)expected updated:(long)updated response:(void (^)(NSNumber *))responseBlock error:(void (^)(Fault *))errorBlock {
    [self compareAndSet:name expected:expected updated:updated responder:[ResponderBlocksContext responderBlocksContext:responseBlock error:errorBlock]];
}

// IAtomicCounters factory
-(id <IAtomicCounters>)of:(NSString *)name {
    return [AtomicCountersFactory create:name];
}

@end
