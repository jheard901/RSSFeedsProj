//
//  DBManager.h
//  wk3_Agn_End
//
//  Created by User on 10/17/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

//for more info about using SQLite look here: https://www.sqlite.org/datatype3.html

@class NewsObject;



@interface DBManager : NSObject


@property (nonatomic) sqlite3* primeDB;
@property (strong, nonatomic) NSString* databasePath;

//used specifically for getting the results of loading all objects from db
@property (nonatomic, strong) NSMutableArray *arrResults;
@property (nonatomic, strong) NSMutableArray *arrColumnNames;



- (id) init;
- (instancetype)initWithFilename:(NSString*)filename; //filename typically will be @"articles.db"

- (void)saveNewsObject:(NewsObject*)newsObject;
//- (NewsObject*)loadNewsObject:(int)rowID; //loads a specific object
- (void)loadAllNewsObjects; //sets values of array results to be used from the db
- (void)deleteNewsObjectAt:(int)rowID; //deletes a specific object from db based off the row id
- (void)deleteNewsObjectTitled:(NSString*)newsTitle;
- (BOOL)isArticleInDB:(NSString*)newsTitle;



@end





