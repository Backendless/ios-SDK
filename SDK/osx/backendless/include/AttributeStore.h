//
//  AttributeStore.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 19.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICastingAttributeStore.h"

@interface AttributeStore : NSObject <ICastingAttributeStore> {
	NSMutableDictionary	*attributes;
}

-(id)initWithAttributes:(NSDictionary *)values;
-(id)initWithAttributeStore:(id <IAttributeStore>)values;
@end
