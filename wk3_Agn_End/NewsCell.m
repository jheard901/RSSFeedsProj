//
//  NewsCell.m
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)pressedFavoritesButton:(UIButton *)sender
{
    [self.delegate newsCellPressedFavorites:self];
}
@end
