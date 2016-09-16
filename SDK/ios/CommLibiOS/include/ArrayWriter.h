//
//  ArrayWriter.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 11.04.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"

@interface ArrayWriter : NSObject <ITypeWriter> {
	id <ITypeWriter> referenceWriter;
}

@end
