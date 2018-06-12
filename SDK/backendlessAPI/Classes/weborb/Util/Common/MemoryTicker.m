//
//  MemoryTicker.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */


#import "MemoryTicker.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation MemoryTicker
@synthesize inBytes, asNumber;

-(id)init {	
	
    if ( (self=[super init] )) {
        responder = nil;
        selGetMemory = nil;
        inBytes = NO;
        asNumber = NO;
        tick = 1.0f;
    }
	
	return self;
}

-(id)initWithResponder:(id)_responder andMethod:(SEL)method {	
	
    if ( (self=[super init] )) {
        responder = [_responder retain];
        selGetMemory = method;
        inBytes = NO;
        asNumber = NO;
        
        [self tickerStart:1.0f];
    }
	
	return self;
}

-(void)dealloc {
    
    [self tickerStop];
    
    if (responder)
        [responder release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Private Methods

-(void)tickerAction {    
    id obj = (asNumber) ? (id)[NSNumber numberWithDouble:[self getAvailableMemory]] : (id)[self showAvailableMemory];
    [responder performSelector:selGetMemory withObject:obj];
    [self performSelector:@selector(tickerAction) withObject:nil afterDelay:tick];    
}

#pragma mark -
#pragma mark Public Methods

-(void)applicationUsedMemoryReport {
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if ( kerr == KERN_SUCCESS ) {
        NSLog(@"REPORT MEMORY: App uses %u Kb", (uint)info.resident_size/1024);
    } else {
        NSLog(@"REPORT MEMORY: ERROR = %s", mach_error_string(kerr));
    }
}

+(double)getAvailableMemoryInBytes {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if (kernReturn != KERN_SUCCESS)
		return NSNotFound;
	
	return (vm_page_size * vmStats.free_count);
}

+(double)getAvailableMemoryInKiloBytes {
	return [MemoryTicker getAvailableMemoryInBytes]/1024.0;
}

+(NSString *)showAvailableMemoryInBytes {
    return [NSString stringWithFormat:@"%g", [MemoryTicker getAvailableMemoryInBytes]];
}

+(NSString *)showAvailableMemoryInKiloBytes {
    return [NSString stringWithFormat:@"%g", [MemoryTicker getAvailableMemoryInKiloBytes]];
}

-(double)getAvailableMemory {
	return (inBytes) ? [MemoryTicker getAvailableMemoryInBytes] : [MemoryTicker getAvailableMemoryInKiloBytes];
}

-(NSString *)showAvailableMemory {
    return [NSString stringWithFormat:@"%g", [self getAvailableMemory]];
}

-(void)tickerStart:(float)aTick {
    tick = aTick;
    [self tickerStop];
    [self tickerStart];
}

-(void)tickerStart {    
    if (responder && selGetMemory && [responder respondsToSelector:selGetMemory]) 
        [self performSelector:@selector(tickerAction) withObject:nil afterDelay:tick];
}

-(void)tickerStop {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
