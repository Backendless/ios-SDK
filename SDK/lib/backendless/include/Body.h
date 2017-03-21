//
//  Body.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 27.06.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Body : NSObject {
    NSString    *serviceUri;
    NSString    *responseUri;
    id          dataObject;
    id          responseDataObject;
}
@property (nonatomic, assign) NSString *serviceUri;
@property (nonatomic, assign) NSString *responseUri;
@property (nonatomic, assign) id dataObject;
@property (nonatomic, assign) id responseDataObject;

-(id)initWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length;
+(id)bodyWithObject:(id)dataObj serviceURI:(NSString *)serviceURI responseURI:(NSString *)responseURI length:(int)length;
@end
