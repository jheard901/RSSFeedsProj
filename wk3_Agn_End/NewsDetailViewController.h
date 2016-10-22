//
//  NewsDetailViewController.h
//  wk3_Agn_End
//
//  Created by User on 10/16/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>


@class NewsObject;
@class ReachabilityManager;


@interface NewsDetailViewController : UIViewController



@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsDateLabel;

@property (nonatomic, assign) NSString* newsSourceURL; //this will be passed to the UIWebView controller

@property (nonatomic, strong) NewsObject* newsObjectData;

//used only for checking connection to a web url before proceeding
@property (weak, nonatomic) ReachabilityManager* rchManager;


- (IBAction)pressedShowSourceButton:(UIButton *)sender;




@end


