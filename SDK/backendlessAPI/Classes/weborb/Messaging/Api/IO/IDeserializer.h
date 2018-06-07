//
//  IDeserializer.h
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

@class ParseContext, FlashorbBinaryReader;

@protocol IDeserializer <NSObject>
-(id)deserialize;
-(id)deserializeAdapted:(BOOL)adapt;
-(int)getVersion;
@optional
-(id)deserialize:(char *)buffer;
-(id)deserialize:(char *)buffer context:(ParseContext *)context;
-(id)deserialize:(char *)buffer adapt:(BOOL)adapt;
-(id)deserialize:(char *)buffer adapt:(BOOL)adapt context:(ParseContext *)context;
-(FlashorbBinaryReader *)getStream;
-(ParseContext *)getContext;
@end
