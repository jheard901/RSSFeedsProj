//
//  NewsCell.h
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NewsCell;



@protocol NewsCellDelegate <NSObject>

- (void)newsCellPressedFavorites: (NewsCell*)newsCell;

@end





@interface NewsCell : UITableViewCell

@property (nonatomic, weak) id <NewsCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


- (IBAction)pressedFavoritesButton:(UIButton *)sender;



@end


