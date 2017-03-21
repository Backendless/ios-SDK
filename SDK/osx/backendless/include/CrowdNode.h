//
//  CrowdNode.h
//  Common
//
//  Created by Вячеслав Вдовиченко on 28.09.10.
//  Copyright 2010 Electrosparkles Games, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CrowdNode : NSObject {
	NSMutableDictionary		*node;		
}
@property (nonatomic, assign, readonly) NSMutableDictionary	*node;

-(BOOL)push:(NSString *)key withObject:(id)it;
-(BOOL)add:(NSString *)key withObject:(id)it;
-(id)get:(NSString *)key;
-(BOOL)pop:(NSString *)key withObject:(id)it;
-(BOOL)del:(NSString *)key;
-(int)count;
-(NSArray *)keys;
-(void)clear;
-(Class)nodeClass;
@end
