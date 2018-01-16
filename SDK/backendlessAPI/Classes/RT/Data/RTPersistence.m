//
//  RTPersistence.m
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2017 BACKENDLESS.COM. All Rights Reserved.
 *
 *  NOTICE: All information contained herein is, and remains the property of Backendless.com and its suppliers,
 *  if any. The intellectual and technical concepts contained herein are proprietary to Backendless.com and its
 *  suppliers and may be covered by U.S. and Foreign Patents, patents in process, and are protected by trade secret
 *  or copyright law. Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Backendless.com.
 *
 *  ********************************************************************************************************************
 */

#import "RTPersistence.h"
#import "Backendless.h"
#import "RTFactory.h"

@implementation RTPersistence

-(RTDataStore *)of:(Class)entityClass {
    return [rtFactory createDataStore:[backendless.persistenceService getEntityName:NSStringFromClass(entityClass)] withEntity:entityClass dataStoreType:DATASTOREFACTORY];
}

-(RTDataStore *)ofTable:(NSString *)tableName {
     return [rtFactory createDataStore:tableName withEntity:nil dataStoreType:MAPDRIVENDATASTORE];
}

@end
