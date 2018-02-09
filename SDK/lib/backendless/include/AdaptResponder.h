//
//  AdaptResponder.h
//  backendlessAPI
//
//  Created by Olga Danylova on /8/218.
//  Copyright © 2018 BACKENDLESS.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Responder.h"
#import "IResponseAdapter.h"

@interface AdaptResponder : Responder

-(instancetype)initWithResponder:(Responder *)respoder responseAdapter:(id<IResponseAdapter>)responseAdapter;

@end
