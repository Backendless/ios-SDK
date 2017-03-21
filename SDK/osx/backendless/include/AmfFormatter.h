//
//  AmfFormatter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 28.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProtocolFormatter.h"
#import "ReferenceCache.h"
#import "ObjectSerializer.h"

@interface AmfFormatter : IProtocolFormatter {
    ObjectSerializer    *objectSerializer;
	ReferenceCache		*referenceCache;
}

@end
