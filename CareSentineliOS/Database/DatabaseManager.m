//
//  DatabaseManager.m
//  CareSentineliOS
//
//  Created by Mike on 5/20/15.
//  Copyright (c) 2015 MobileAWS. All rights reserved.
//

#import "DatabaseManager.h"
#import "sqlite3.h"
#import "BaseModel.h"

@implementation DatabaseManager{
    NSString *databasePath;
    sqlite3 *database;
}

static DatabaseManager *sharedInstance = nil;

+(DatabaseManager *)getSharedIntance{
    if (sharedInstance == nil) {
        sharedInstance = [[DatabaseManager alloc] initWithDatabaseName:@"CareSentinel.db"];
    }
    
    sharedInstance.keepConnection = false;
    return sharedInstance;
}


- (id)initWithDatabaseName:(NSString *)name {
    self = [super init];
    if (self){
        NSString *docFolder;
        NSArray *tempFolders;
        self->database = nil;
        tempFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, TRUE);
        if ([tempFolders count] > 0) {
            docFolder = tempFolders[0];
            self->databasePath = [docFolder stringByAppendingString:[@"/" stringByAppendingString:name]];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:self->databasePath]) {
                /** Read the initialization script file */
                NSString *scriptsPath = [[NSBundle mainBundle] pathForResource:@"database_v1" ofType:@"sql"];
                NSString *sqlInit = [NSString stringWithContentsOfFile:scriptsPath encoding:NSUTF8StringEncoding error:NULL];
                sqlite3_stmt *statement;
                /** Open the database */
                int result = -1;
                sqlite3_open([self->databasePath UTF8String], &self->database);
                const char *sql = [sqlInit UTF8String];
                sqlInit = nil;
                const char *sqlTail;
                do{
                    result = sqlite3_prepare_v2(database, sql, -1, &statement, &sqlTail);
                    if(result  == SQLITE_OK){
                        sqlite3_step(statement);
                        sql = sqlTail;
                    }
                    else{
                        NSLog(@"Error while creating the database: %s",sqlite3_errmsg(database));
                    }
                }while (result == SQLITE_OK && strlen(sqlTail) > 0);
                /** Clean and Close to finish creation process */
                sqlite3_finalize(statement);
                statement = nil;
                [self close];
            }
        }
    }
    return self;
}



-(id<BaseModel>)save:(id<BaseModel>)data{
    
    NSDictionary *properties = [[(NSObject *)data class] getPropertiesMapping];
    NSString *tableName = [[(NSObject *)data class] getTableName];
    NSMutableArray *valuesArray = [[NSMutableArray alloc] init];
    NSArray *fields = [properties allKeys];
    
    for (int i = 0; i < fields.count; i++) {
        id tempValue = [(NSObject *)data valueForKey:[properties valueForKey:[fields objectAtIndex:i]]];
        if(tempValue == nil){
            [valuesArray addObject:@"NULL"];
        }
        else{
            [valuesArray addObject:[NSString stringWithFormat:@"\"%@\"", tempValue]];
        }
    }
    
    NSString *insertQuery = [NSString stringWithFormat:@"INSERT INTO %@(%@)VALUES(%@)",tableName,[fields componentsJoinedByString:@","],[valuesArray componentsJoinedByString:@","]];
    if (self->database == nil) {
        sqlite3_open([self->databasePath UTF8String], &self->database);
    }
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(self->database, [insertQuery UTF8String], -1, &statement, nil);
    if(sqlite3_step(statement) != SQLITE_DONE){
        sqlite3_finalize(statement);
        NSLog(@"Error executing Insert/Update Query: %s",sqlite3_errmsg(self->database));
        if (self.keepConnection == false) {[self close];}
        return nil;
    }
    sqlite3_finalize(statement);
    NSNumber  *tmpId = [[NSNumber alloc] initWithLong:sqlite3_last_insert_rowid(self->database)];
    [(NSObject *)data setValue:(tmpId) forKey:@"id"];
    if (self.keepConnection == false) {[self close];}
    return data;
}

-(id)findById:(NSNumber *)targetId{
    return nil;
}


-(NSMutableArray *)listWithModel:(Class)targetModel condition:(NSString *)condition{
    NSDictionary * properties = [(id)targetModel getPropertiesMapping];
    NSString * model = [(id)targetModel getTableName];
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",[[properties allKeys] componentsJoinedByString:@","],model,condition];
    sqlite3_stmt *statement;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (self->database == nil) {
        sqlite3_open([self->databasePath UTF8String], &self->database);
    }
    if(sqlite3_prepare_v2(self->database,[query UTF8String],-1,&statement,NULL) == SQLITE_OK){
        while(sqlite3_step(statement) == SQLITE_ROW){
            id<BaseModel> currentObject = [[targetModel alloc] init];
            NSArray *fields = [properties allKeys];
            for (int i = 0; i < fields.count; i++) {
                id value = [self getColumnValueForRow:i withStatement:statement];
                [(NSObject *)currentObject setValue:value forKey:[properties objectForKey:[fields objectAtIndex:i]]];
            }
            [result addObject:currentObject];
        }
    }
    sqlite3_finalize(statement);
    if (self.keepConnection == false) {[self close];}
    return result;
}

-(id)findWithCondition:(NSString *)condition forModel:(Class)targetClass{
    NSDictionary * properties = [(id)targetClass getPropertiesMapping];
    NSString * model = [(id)targetClass getTableName];
    NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@",[[properties allKeys] componentsJoinedByString:@","],model,condition];
    if (self->database == nil) {
        sqlite3_open([self->databasePath UTF8String], &self->database);
    }
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(self->database, [query UTF8String], -1, &statement, nil);
    if(sqlite3_step(statement) == SQLITE_ROW){
        id<BaseModel> currentObject = [[targetClass alloc] init];
        NSArray *fields = [properties allKeys];
        for (int i = 0; i < fields.count; i++) {
            id value = [self getColumnValueForRow:i withStatement:statement];
            [(NSObject *)currentObject setValue:value forKey:[properties objectForKey:[fields objectAtIndex:i]]];
        }

        if (self.keepConnection == false) {[self close];}
        sqlite3_finalize(statement);
        return currentObject;
    }
    sqlite3_finalize(statement);
    if (self.keepConnection == false) {[self close];}
    return nil;
}

-(id)getColumnValueForRow:(int)row withStatement:(sqlite3_stmt *)statement{
    int type = sqlite3_column_type(statement, row);
    switch (type) {
        case SQLITE_TEXT:
            return [[NSString alloc] initWithUTF8String: (const char *)sqlite3_column_text(statement, row)];
        case SQLITE_INTEGER:
            return [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, row)];
        case SQLITE_FLOAT:
            return [[NSNumber alloc] initWithDouble: sqlite3_column_double(statement, row)];
        default:
            break;
    }
    return nil;
}

-(NSInteger)countWithQuery:(NSString *)condition{
    NSString *targetQuery = [NSString stringWithFormat:@"SELECT COUNT(*) %@",condition];
    if (self->database == nil) {
        sqlite3_open([self->databasePath UTF8String], &self->database);
    }
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(self->database, [targetQuery UTF8String], -1, &statement, nil);
    if(sqlite3_step(statement) == SQLITE_ROW){
        NSNumber *targetCount = [self getColumnValueForRow:0 withStatement:statement];
        sqlite3_finalize(statement);
        if (self.keepConnection == false) {[self close];}
        return [targetCount integerValue];
    }
    sqlite3_finalize(statement);
    if (self.keepConnection == false) {[self close];}
    return 0;

}

-(void)insert:(NSString *)insertQuery{
    if (self->database == nil) {
        sqlite3_open([self->databasePath UTF8String], &self->database);
    }
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(self->database, [insertQuery UTF8String], -1, &statement, nil);
    if(sqlite3_step(statement) != SQLITE_DONE){
        NSLog(@"Error executing Insert/Update Query: %s",sqlite3_errmsg(self->database));
        if (self.keepConnection == false) {[self close];}
        sqlite3_finalize(statement);
        return;
    }
    if (self.keepConnection == false) {[self close];}
}

-(void)close{
    sqlite3_close(self->database);
    self->database = nil;
}
@end
