//
//  NewsObject.m
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "NewsObject.h"



@implementation NewsObject


@synthesize title;
@synthesize sourceURL;
@synthesize publicationDate;
@synthesize newsDescription;
@synthesize imageURL;
@synthesize imageData;


//this is being used for testing purposes
- (instancetype) initWithTitle:(NSString *)newsTitle SourceURL:(NSString *)source PublicationDate:(NSString *)pubDate
{
    self = [super init];
    if(self)
    {
        self.title = newsTitle;
        self.sourceURL = source;
        self.publicationDate = pubDate;
    }
    return self;
}

//assigns all parameters for a news object (assumes an active connection for obtaining imageData)
- (instancetype) initWithAllTitle:(NSString *)newsTitle SourceURL:(NSString *)source PublicationDate:(NSString *)pubDate NewsDescription:(NSString *)description ImageURL:(NSString *)imgURL
{
    self = [super init];
    if(self)
    {
        self.title = newsTitle;
        self.sourceURL = source;
        self.publicationDate = pubDate;
        self.newsDescription = description;
        self.imageURL = imgURL;
        
        
        NSURL* imgUrl = [NSURL URLWithString:imgURL];
        
        NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:imgUrl completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            
            if(data)
            {
                self.imageData = data;
            }
            else
            {
                NSLog(@"Image download error occurred.");
            }
        }];
        
        //maybe this should be put inside main thread?
        [downloadTask resume];
    }
    return self;
}

//simplified initialization specifically for loading items from the SQL db
- (instancetype)initFromSQLTitle:(NSString *)newsTitle NewsDescription:(NSString *)description ImageURL:(NSString *)imgURL ImageData:(NSData *)imgData
{
    self = [super init];
    if(self)
    {
        self.title = newsTitle;
        self.newsDescription = description;
        self.imageURL = imgURL;
        self.imageData = imgData;
        
        //placeholder text
        self.sourceURL = @"Offline";
        self.publicationDate = @"Offline";
    }
    return self;
}

- (instancetype)initFromSQLAllTitle:(NSString *)newsTitle SourceURL:(NSString *)source PublicationDate:(NSString *)pubDate NewsDescription:(NSString *)description ImageURL:(NSString *)imgURL ImageData:(NSData *)imgData
{
    self = [super init];
    if(self)
    {
        self.title = newsTitle;
        self.sourceURL = source;
        self.publicationDate = pubDate;
        self.newsDescription = description;
        self.imageURL = imgURL;
        self.imageData = imgData;
    }
    return self;
}

@end


