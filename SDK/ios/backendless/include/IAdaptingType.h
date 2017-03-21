//
//  IAdaptingType.h
//  RTMPStream
//
//  Created by Вячеслав Вдовиченко on 14.03.11.
//  Copyright 2011 The Midnight Coders, Inc. All rights reserved.
//

@protocol IAdaptingType <NSObject>
-(NSString *)description;
-(Class)getDefaultType;
-(id)defaultAdapt;
-(id)adapt:(Class)type;
-(BOOL)canAdapt:(Class)formalArg;
-(BOOL)equals:(id)obj pairs:(NSDictionary *)visitedPairs;
@end
