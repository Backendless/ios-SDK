//
//  ISDatabase.h
//  backendlessAPI
/*
 * *********************************************************************************************************************
 *
 *  BACKENDLESS.COM CONFIDENTIAL
 *
 *  ********************************************************************************************************************
 *
 *  Copyright 2014 BACKENDLESS.COM. All Rights Reserved.
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
#import <sqlite3.h> 

@interface ISDatabase : NSObject { 
    NSString *pathToDatabase; 	
    BOOL logging; 	
    sqlite3 *database; 
} 
@property (nonatomic, retain) NSString *pathToDatabase; 
@property (nonatomic) BOOL logging; 

- (id)initWithPath: (NSString *)filePath; 
- (id)initWithFileName: (NSString *)fileName; 
- (NSArray *)executeSql: (NSString *)sql; 
- (NSArray *)executeSql: (NSString *)sql withParameters:(NSArray *)parameters;
- (NSArray *)executeSqlWithParameters: (NSString *)sql, ... ;
- (NSArray *)tableNames;
- (NSArray *)columnsForTableName: (NSString *)tableName;
- (void)beginTransaction;
- (void)commit;
- (void)rollback;
- (NSUInteger)lastInsertRowId;
- (NSString *)allowableText: (NSString *)text;

@end

