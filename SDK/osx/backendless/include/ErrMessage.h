//
//  ErrMessage.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/14/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AckMessage.h"


@interface ErrMessage : AckMessage {
    id          rootCause;
    NSString    *faultString;
    NSString    *faultCode;
    id          extendedData;
    NSString    *faultDetail;
}
@property (nonatomic, assign) id rootCause;
@property (nonatomic, assign) NSString *faultString; 
@property (nonatomic, assign) NSString *faultCode;
@property (nonatomic, assign) id extendedData;
@property (nonatomic, assign) NSString *faultDetail;
@end
