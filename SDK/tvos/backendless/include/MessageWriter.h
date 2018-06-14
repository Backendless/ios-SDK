//
//  MessageWriter.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2018 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import <Foundation/Foundation.h>
#import "ITypeWriter.h"
#import "IProtocolFormatter.h"

@interface MessageWriter : NSObject {
	NSMutableDictionary	*writers;
	NSMutableDictionary	*functionalWriters;
	NSMutableDictionary	*additionalWriters;
}

// Singleton accessor:  this is how you should ALWAYS get a reference to the class instance.  Never init your own. 
+(MessageWriter *)sharedInstance;
//
-(void)writeObject:(id)obj format:(IProtocolFormatter *)formatter;
-(void)addAdditionalTypeWriter:(Class)mappedType typeWriter:(id <ITypeWriter>)writer;
-(void)cleanAdditionalWriters;
-(id <ITypeWriter>)getStandardTypeWriter:(Class)type;
-(id <ITypeWriter>)getWriter:(id)obj format:(IProtocolFormatter *)formatter;
-(id <ITypeWriter>)getWriter:(Class)type format:(IProtocolFormatter *)formatter withInterfaces:(BOOL)checkInterfaces;
@end
