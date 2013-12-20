//
//  ISDatabase.h
//
//  Created by Vyacheslav Vdovichenko on 20.05.10.
//  Copyright 2010 OpenWorld. All rights reserved.
//

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

