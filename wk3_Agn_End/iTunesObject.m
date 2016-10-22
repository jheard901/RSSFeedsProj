//
//  iTunesObject.m
//  testing001
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "iTunesObject.h"

@implementation iTunesObject



- (instancetype)initWithAlbum:(NSString *)albumName Genre:(NSString *)genreName Artist:(NSString *)artistName Price:(NSString *)priceTag ReleaseDate:(NSString *)releaseDate AlbumImageURL:(NSString *)albumImageURL AlbumSourceURL:(NSString *)albumSourceURL
{
    self = [super init];
    if(self)
    {
        
        self.album = albumName;
        self.genre = genreName;
        self.artist = artistName;
        self.price = priceTag;
        self.date = releaseDate;
        self.imageURL = albumImageURL;
        self.sourceURL = albumSourceURL;
        
    }
    return self;
}



@end




