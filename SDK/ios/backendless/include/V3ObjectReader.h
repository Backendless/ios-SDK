//
//  V3ObjectReader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 01.07.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ITypeReader.h"


@interface V3ObjectReader : NSObject <ITypeReader> {
    
}
+(id)typeReader;
@end


@interface ClassInfo : NSObject {
    BOOL        looseProps;
    NSString    *className;
    BOOL        externalizable;
    NSMutableArray *props;
}
@property BOOL looseProps;
@property (nonatomic, assign) NSString *className;
@property BOOL externalizable;
@property (nonatomic, assign, readonly) NSMutableArray *props;

-(void)addProperty:(NSString *)propName;
-(int)getPropertyCount;
-(NSString *)getProperty:(int)index;
@end
