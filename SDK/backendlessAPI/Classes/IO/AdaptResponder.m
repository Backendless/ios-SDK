//
//  AdaptResponder.m
//  backendlessAPI
//
//  Created by Olga Danylova on /8/218.
//  Copyright © 2018 BACKENDLESS.COM. All rights reserved.
//

#import "AdaptResponder.h"
#import "Responder.h"

@interface AdaptResponder() {
    Responder *_responder;
    id<IResponseAdapter> _adapter;
}
@end

@implementation AdaptResponder

-(instancetype)initWithResponder:(Responder *)respoder responseAdapter:(id<IResponseAdapter>)responseAdapter {
    if (self = [super init]) {
        _responder = respoder;
        _adapter = responseAdapter;
    }
    return self;
}

-(id)responseHandler:(id)response {
    id adaptedResponse = [_adapter adapt:response];
    return [_responder responseHandler:adaptedResponse];
}

@end
