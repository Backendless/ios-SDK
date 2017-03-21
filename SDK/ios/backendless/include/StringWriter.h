//
//  StringWriter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"

@interface StringWriter : NSObject <ITypeWriter>
-(id)initIsReferenceable:(BOOL)value;
+(id)writerIsReferenceable:(BOOL)value;
@end
