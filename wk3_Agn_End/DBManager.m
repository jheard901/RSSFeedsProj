//
//  DBManager.m
//  wk3_Agn_End
//
//  Created by User on 10/17/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "DBManager.h"
#import "NewsObject.h"


@implementation DBManager

- (id)init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

//the primary way to init the DBManager
- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if(self)
    {
        
        /* create a file for database if it does not already exist */
        
        NSString* docsDirectory;
        NSArray* dirPaths;
        
        //store an array of paths to the specified location on disk
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        //set our path to use for default location of the db (in this case, we have appended the filename to the pathname)
        docsDirectory = [dirPaths objectAtIndex:0];
        self.databasePath = [[NSString alloc] initWithString:[docsDirectory stringByAppendingPathComponent:filename]];
        
        NSFileManager* filemgr = [NSFileManager defaultManager];
        
        if([filemgr fileExistsAtPath:self.databasePath] == NO)
        {
            //UTF8String is a pointer to a struct within a string (used specifically for SQLite)
            const char* dbPath = [self.databasePath UTF8String];
            
            //if the path to the specified file can be opened, proceed
            if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
            {
                //object to save errors
                char* errorMsg;
                
                //create the DB (this text apparently isn't just for notes sake, it looks like a script for SQLite)
                const char* sql_stmt = "CREATE TABLE IF NOT EXISTS ARTICLES (ID INTEGER PRIMARY KEY AUTOINCREMENT, TITLE TEXT, DESCRIPTION TEXT, URL TEXT UNIQUE, IMAGE BLOB, SOURCE TEXT UNIQUE, DATE TEXT)";
                
                //show error if can't open table
                if( sqlite3_exec(self.primeDB, sql_stmt, NULL, NULL, &errorMsg) != SQLITE_OK)
                {
                    NSLog(@"%@", [NSString stringWithFormat:@"Failed to create table. Error: %s", sqlite3_errmsg(_primeDB)]);
                }
                sqlite3_close(self.primeDB);
                
            }
            else
            {
                NSLog(@"Failed to open/create database.");
            }
            
        }
        
    }
    return self;
}

//record values from the news object into SQLite db | on saving images: http://stackoverflow.com/questions/5039343/save-image-data-to-sqlite-database-in-iphone
- (void)saveNewsObject:(NewsObject *)newsObject
{
    //create sql statement
    sqlite3_stmt* statement;
    const char* dbPath = [self.databasePath UTF8String];
    
    //if the path can be opened
    if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
    {
        //backslashes i.e. '\' before quotes inside a string literal allows you to uses quotes within the string (its like a command similar to allowing \n for newline)
        //prepare a script to send SQLite db object | old method handling only strings
        //NSString* insertSQL = [NSString stringWithFormat:@"INSERT INTO ARTICLES (title, description, url, image) VALUES (\"%@\", \"%@\", \"%@\", \"?\")", newsObject.title, newsObject.newsDescription, newsObject.imageURL, newsObject.imageData];
        //NSLog(@"%@", insertSQL); //debug output optional
        
        //create the SQL query
        const char* insert_stmt = "INSERT INTO ARTICLES (title, description, url, image, source, date) VALUES (?, ?, ?, ?, ?, ?)";
        
        //not sure what this does (no local documentation for it)
        if(sqlite3_prepare_v2(self.primeDB, insert_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //if the SQLite statment checks out, then start binding values before commiting them to the db
            sqlite3_bind_text(statement, 1, [newsObject.title UTF8String], -1, SQLITE_TRANSIENT); //this -1 appears quite often...
            sqlite3_bind_text(statement, 2, [newsObject.newsDescription UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [newsObject.imageURL UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_blob(statement, 4, [newsObject.imageData bytes], (int)[newsObject.imageData length], SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [newsObject.sourceURL UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [newsObject.publicationDate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
        }
        else
        {
            NSLog(@"Failed to save data. Error: %s", sqlite3_errmsg(self.primeDB));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(self.primeDB);
    }
}


- (void)loadAllNewsObjects
{
    //this is the query specifically being used for the db
    const char* query = "select * from ARTICLES";
    
    
    // Initialize the results array.
    if (self.arrResults != nil)
    {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil)
    {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    
    
    // Open the database.
    sqlite3_stmt* statement;
    const char* dbPath = [self.databasePath UTF8String];
    
    //open the db
    if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
    {
        
        //create the SQL statement to retrieve the data
        const char* query_stmt = query;
        
        //prepare the query
        if(sqlite3_prepare_v2(self.primeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            // Declare an array to keep the data for each fetched row.
            NSMutableArray* arrDataRow;
            
            // Loop through the results and add them to the results array row by row.
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                // Initialize the mutable array that will contain the data of a fetched row.
                arrDataRow = [[NSMutableArray alloc] init];
                
                // Get the total number of columns.
                int totalColumns = sqlite3_column_count(statement);
                
                // Go through all columns and fetch each column data.
                for (int i = 0; i < totalColumns; i++)
                {
                    //we know columns 1-3 are text, and column 4 is NSData
                    if(i < 4)
                    {
                        // Convert the column data to text (characters).
                        char* dbDataAsChars = (char*)sqlite3_column_text(statement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL)
                        {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        else
                        {
                            //nil values cause the arrDataRow to not add a new object, so we manually add a nil object to abide by the hard-code structure of SQL retrieval
                            [arrDataRow addObject:[NSString stringWithFormat:@"Column %i is nil.", i]];
                        }
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns)
                        {
                            dbDataAsChars = (char *)sqlite3_column_name(statement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                    }
                    else if(i == 4) //this is the image blob
                    {
                        int length = sqlite3_column_bytes(statement, i);
                        NSData* imgData = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:length];
                        
                        //if the image data is not nil, then add it to the current row array
                        if(imgData != nil)
                        {
                            [arrDataRow addObject:imgData];
                        }
                        
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns)
                        {
                            char* dbDataAsChars = (char *)sqlite3_column_name(statement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        
                    }
                    else //the remaining text
                    {
                        // Convert the column data to text (characters).
                        char* dbDataAsChars = (char*)sqlite3_column_text(statement, i);
                        
                        // If there are contents in the currenct column (field) then add them to the current row array.
                        if (dbDataAsChars != NULL)
                        {
                            // Convert the characters to string.
                            [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                        }
                        else
                        {
                            //nil values cause the arrDataRow to not add a new object, so we manually add a nil object to abide by the hard-code structure of SQL retrieval
                            [arrDataRow addObject:[NSString stringWithFormat:@"Column %i is nil.", i]];
                        }
                        // Keep the current column name.
                        if (self.arrColumnNames.count != totalColumns)
                        {
                            dbDataAsChars = (char *)sqlite3_column_name(statement, i);
                            [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                }
                
                // Store each fetched data row in the results array, but first check if there is actually data.
                if (arrDataRow.count > 0)
                {
                    //original method
                    //[self.arrResults addObject:arrDataRow];
                    
                    /* with this way, we reference a newsObject directly, instead of through a 2D array for arrResults */
                    
                    //get all the data harvested from db and put it into a single newsObject
                    NSString* newsTitle = [arrDataRow objectAtIndex:1];
                    NSString* newsDescription = [arrDataRow objectAtIndex:2];
                    NSString* newsImageURL = [arrDataRow objectAtIndex:3];
                    NSData* newsData = [arrDataRow objectAtIndex:4];
                    NSString* newsSource = [arrDataRow objectAtIndex:5];
                    NSString* newsDate = [arrDataRow objectAtIndex:6];
                    NewsObject* aNewsObject = [[NewsObject alloc] initFromSQLAllTitle:newsTitle SourceURL:newsSource PublicationDate:newsDate NewsDescription:newsDescription ImageURL:newsImageURL ImageData:newsData];
                    [self.arrResults addObject:aNewsObject];
                }
                
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(self.primeDB);
}

//deletes data from db based off the input row ID
- (void)deleteNewsObjectAt:(int)rowID
{
    //create the statement
    sqlite3_stmt* statement;
    const char* dbPath = [self.databasePath UTF8String];
    
    //open the db
    if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
    {
        //create the SQL statement to delete the data | info from: https://www.tutorialspoint.com/sqlite/sqlite_delete_query.htm
        //NSString* querySQL = [NSString stringWithFormat:@"DELETE FROM CONTACTS WHERE name IS '%@'", self.nameTextField.text]; //original MAC tut code; buggy
        NSString* querySQL = [NSString stringWithFormat:@"DELETE FROM ARTICLES WHERE id = %d", rowID];
        const char* query_stmt = [querySQL UTF8String];
        
        //prepare the query | fix for deleting: http://stackoverflow.com/questions/4300613/cant-delete-row-from-sqlite-database-yet-no-errors-are-issued
        if(sqlite3_prepare_v2(self.primeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //execute the query on success
            sqlite3_step(statement);
            
            //output to notify user it happened
            NSLog(@"Article successfully deleted.");
        }
        else
        {
            //if there is not a row, then the data is not found
            NSLog(@"Could not locate article at row: %d", rowID);
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(self.primeDB); //remember to close the database if it has been successfully opened
    }
}

- (void)deleteNewsObjectTitled:(NSString *)newsTitle
{
    //create the statement
    sqlite3_stmt* statement;
    const char* dbPath = [self.databasePath UTF8String];
    
    //open the db
    if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
    {
        //create the SQL statement to delete the data | info from: https://www.tutorialspoint.com/sqlite/sqlite_delete_query.htm
        NSString* querySQL = [NSString stringWithFormat:@"DELETE FROM ARTICLES WHERE title = \"%@\"", newsTitle];
        const char* query_stmt = [querySQL UTF8String];
        
        //prepare the query | fix for deleting: http://stackoverflow.com/questions/4300613/cant-delete-row-from-sqlite-database-yet-no-errors-are-issued
        if(sqlite3_prepare_v2(self.primeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //execute the query on success
            sqlite3_step(statement);
            
            //output to notify user it happened
            NSLog(@"Article successfully deleted.");
        }
        else
        {
            //if there is not a row, then the data is not found
            NSLog(@"Could not locate article with title: %@", newsTitle);
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(self.primeDB); //remember to close the database if it has been successfully opened
    }
}

//return true if it find a column in database with the specified title
- (BOOL)isArticleInDB:(NSString *)newsTitle
{
    BOOL bFoundArticle = NO;
    sqlite3_stmt* statement;
    const char* dbPath = [self.databasePath UTF8String];
    
    //open the db
    if(sqlite3_open(dbPath, &_primeDB) == SQLITE_OK)
    {
        //create the SQL statement to retrieve the data
        NSString* querySQL = [NSString stringWithFormat:@"SELECT title FROM ARTICLES WHERE title = \"%@\"", newsTitle]; //the first declaration of 'title' in this line is arbitrary; it could be anything such as a *, it justs matters whether or not the newsTitle is found in the db 
        const char* query_stmt = [querySQL UTF8String];
        
        //prepare the query
        if(sqlite3_prepare_v2(self.primeDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //if query was ok, we must have a row if the data was there
            if(sqlite3_step(statement) == SQLITE_ROW)
            {
                //if statement is true, then the article already exists in DB
                bFoundArticle = YES;
            }
            else
            {
                bFoundArticle = NO;
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(self.primeDB);
    }
    
    return bFoundArticle;
}


@end





