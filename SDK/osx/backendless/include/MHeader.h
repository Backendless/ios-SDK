//
//  MHeader.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAdaptingType.h"


@interface MHeader : NSObject {
    NSString    *headerName;
    BOOL        mustUnderstand;
    id <IAdaptingType> headerValue;
}
@property (nonatomic, assign) NSString *headerName;
@property BOOL mustUnderstand;
@property (nonatomic, assign) id <IAdaptingType> headerValue;

-(id)initWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name understand:(BOOL)must length:(int)length;
+(id)headerWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name understand:(BOOL)must length:(int)length;
+(id)headerWithObject:(id <IAdaptingType>)dataObj name:(NSString *)name;
@end
