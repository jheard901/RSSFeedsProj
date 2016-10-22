//
//  iTunesObject.h
//  testing001
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iTunesObject : NSObject

- (instancetype) initWithAlbum:(NSString*)albumName Genre:(NSString*)genreName Artist:(NSString*)artistName Price:(NSString*)priceTag ReleaseDate:(NSString*)releaseDate AlbumImageURL:(NSString*)albumImageURL AlbumSourceURL:(NSString*)albumSourceURL;

@property (nonatomic, strong) NSString* album;
@property (nonatomic, strong) NSString* genre;
@property (nonatomic, strong) NSString* artist;
@property (nonatomic, strong) NSString* price;
@property (nonatomic, strong) NSString* date;
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) NSString* sourceURL;

@end


