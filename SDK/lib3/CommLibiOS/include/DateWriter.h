//
//  DateWriter.h
//  CommLibiOS
//
//  Created by Vyacheslav Vdovichenko on 10/19/12.
//  Copyright (c) 2012 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"

@interface DateWriter :  NSObject <ITypeWriter>
-(id)initIsReferenceable:(BOOL)value;
+(id)writerIsReferenceable:(BOOL)value;
@end
