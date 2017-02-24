//
//  SysTimer.h
//  MediaLibiOS
//
//  Created by Vyacheslav Vdovichenko on 12/15/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SysTimer : NSObject {
    uint64_t    start;
    uint64_t    last; 
    double      conversion;
}

-(void)reset;
-(void)set;
-(double)nanoReboot;
-(double)microReboot;
-(double)milliReboot;
-(double)secReboot;
-(double)nanoStart;
-(double)microStart;
-(double)milliStart;
-(double)secStart;
-(double)nanoLast;
-(double)microLast;
-(double)milliLast;
-(double)secLast;
@end
