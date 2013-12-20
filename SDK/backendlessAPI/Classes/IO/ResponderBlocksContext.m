//
//  ResponderBlocksContext.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2012 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "ResponderBlocksContext.h"
#import "DEBUG.h"

typedef void (^ResponseHandlerBlock)(id);
typedef void (^ErrorHandlerBlock)(Fault *);

@interface ResponderBlocksContext () <IResponder>

@property (copy) ResponseHandlerBlock responseBlock;
@property (copy) ErrorHandlerBlock errorBlock;

@end


@implementation ResponderBlocksContext

+(Responder *)responderBlocksContext:(void(^)(id))responseBlock error:(void(^)(Fault *))errorBlock {
    
    ResponderBlocksContext *blocksContext = [ResponderBlocksContext new];
    blocksContext.responseBlock = responseBlock;
    blocksContext.errorBlock = errorBlock;
    
    return [Responder responder:blocksContext selResponseHandler:@selector(responseHandler:) selErrorHandler:@selector(errorHandler:)];
}

-(void)dealloc {
	
	[DebLog logN:@"DEALLOC ResponderBlocksContext"];
 	
	[super dealloc];
}

#pragma mark -
#pragma mark IResponder Methods

-(id)responseHandler:(id)response {
    self.responseBlock(response);
    return response;
}

-(void)errorHandler:(Fault *)fault {
    self.errorBlock(fault);
}

@end
