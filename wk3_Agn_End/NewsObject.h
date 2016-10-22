//
//  NewsObject.h
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NewsObject : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* sourceURL;
@property (nonatomic, strong) NSString* publicationDate;
@property (nonatomic, strong) NSString* newsDescription; //'description' causes errors when used for variable name
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) NSData* imageData; //we should assign the imageData based off the source url of the image (average size is 2-4kb per image)


//based off the imageURL, the imageData will be set
- (instancetype) initWithTitle:(NSString*)newsTitle SourceURL:(NSString*)source PublicationDate:(NSString*)pubDate;
- (instancetype) initWithAllTitle:(NSString*)newsTitle SourceURL:(NSString*)source PublicationDate:(NSString*)pubDate NewsDescription:(NSString*)description ImageURL:(NSString*)imgURL;

//alternate definition for use with loading an object from sqlite db
- (instancetype) initFromSQLTitle:(NSString*)newsTitle NewsDescription:(NSString*)description ImageURL:(NSString*)imgURL ImageData:(NSData*)imgData;
- (instancetype) initFromSQLAllTitle:(NSString*)newsTitle SourceURL:(NSString*)source PublicationDate:(NSString*)pubDate NewsDescription:(NSString*)description ImageURL:(NSString*)imgURL ImageData:(NSData*)imgData;

@end


