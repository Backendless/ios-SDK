//
//  AdaptResponder.m
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


#import "AdaptResponder.h"
#import "Responder.h"

@interface AdaptResponder() {
    Responder *_responder;
    id<IResponseAdapter> _adapter;
}
@end

@implementation AdaptResponder

-(instancetype)initWithResponder:(Responder *)responder responseAdapter:(id<IResponseAdapter>)responseAdapter {
    if (self = [super init]) {
        _responder = responder;
        _adapter = responseAdapter;
    }
    return self;
}

-(id)responseHandler:(id)response {
    id adaptedResponse = [_adapter adapt:response];
    if ([adaptedResponse isKindOfClass:[Fault class]]) {
        [_responder errorHandler:adaptedResponse];
    }
    else {
       [_responder responseHandler:adaptedResponse];
    }
    return _responder;
}

@end
