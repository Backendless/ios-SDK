//
//  ClassDefinition.h
//  RTMPStream
//
//  Created by Vyacheslav Vdovichenko on 7/11/11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ClassDefinition : NSObject {
    NSMutableDictionary *members;
    NSString            *className;
}
@property (nonatomic, assign, readonly) NSMutableDictionary *members;
@property (nonatomic, assign) NSString *className;

-(void)addMemberInfo:(NSString *)name member:(id)memberInfo;
-(BOOL)containsMember:(NSString *)name;
@end
