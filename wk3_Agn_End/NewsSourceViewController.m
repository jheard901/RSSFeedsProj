//
//  NewsSourceViewController.m
//  wk3_Agn_End
//
//  Created by User on 10/16/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "NewsSourceViewController.h"

@interface NewsSourceViewController ()

@end

@implementation NewsSourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //I think what I want to do is program the webpage to only load text/html first, and block loading any images (because they take too long initially). After that, then a 2nd pass to load images should start asynchronously so users can look at the web content earlier, with the images starting to pop in as they read it. NOTE: The long load issue only happens on some sites, not all of them so the error probably could fall on the web developers not optimizing their website, because some of the sites that I loaded in webview came up near instantly with the text displayed, and then the images slowly streaming in 1 by 1.
    //info that could help with fixing long load times from waiting for entire page to load: http://www.icab.de/blog/2009/08/18/url-filtering-with-uiwebview-on-the-iphone/
    
    //attempt to load the web page from webURL | info: http://sourcefreeze.com/ios-webview-uiwebview-example/
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
