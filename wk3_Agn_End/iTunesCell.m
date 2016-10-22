//
//  iTunesCell.m
//  testing001
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "iTunesCell.h"

@implementation iTunesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _bLoadingImage = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
