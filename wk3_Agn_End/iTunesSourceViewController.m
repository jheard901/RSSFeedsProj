//
//  iTunesSourceViewController.m
//  wk3_Agn_End
//
//  Created by User on 10/18/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "iTunesSourceViewController.h"

@interface iTunesSourceViewController ()

@end

@implementation iTunesSourceViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //on making custom ToDo: or warnings: http://stackoverflow.com/questions/16913055/how-can-i-mark-to-do-comments-in-xcode
    
    NSURL* debugUrl = [NSURL URLWithString:@"http://mobileappscompany.com"];
    //cannot load the domain "itunes.apple.com" in simulator; explained here: http://stackoverflow.com/questions/11244337/itunes-link-cannot-be-opened-in-ui-web-view so I assume it will work tested on an actual device?
    
#warning NSURL* url causes an exception in Xcode on simulator - this was because I had webURL set up as 'assign' instead of 'strong'; on actual device change urlRequest to use url
    NSURL* url = [NSURL URLWithString:self.webURL];
    NSURLRequest* urlRequest = [NSURLRequest requestWithURL:url];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //dispatch_async here so app is not frozen while loading web page
        [self.sourceWebView loadRequest:urlRequest];
    });
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/





@end





