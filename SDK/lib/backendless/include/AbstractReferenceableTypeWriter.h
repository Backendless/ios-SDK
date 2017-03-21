//
//  AbstractReferenceableTypeWriter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 30.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"
#import "ObjectReferenceWriter.h"

@interface AbstractReferenceableTypeWriter : NSObject <ITypeWriter> {
	ObjectReferenceWriter *referenceWriter;
}

@end
