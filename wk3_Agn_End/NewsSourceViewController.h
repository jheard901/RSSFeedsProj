//
//  NewsSourceViewController.h
//  wk3_Agn_End
//
//  Created by User on 10/16/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface NewsSourceViewController : UIViewController


@property (nonatomic, assign) NSString* webURL;

@property (weak, nonatomic) IBOutlet UIWebView *sourceWebView;



@end




