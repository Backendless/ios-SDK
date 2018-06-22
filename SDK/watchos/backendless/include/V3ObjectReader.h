//
//  V3ObjectReader.h
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
