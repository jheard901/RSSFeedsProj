//
//  NewsDetailViewController.m
//  wk3_Agn_End
//
//  Created by User on 10/16/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "NewsObject.h"
#import "NewsSourceViewController.h"
#import "ReachabilityManager.h"


@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //fill up labels and imageView with data passed from previous view
    self.newsTitleLabel.text = self.newsObjectData.title;
    self.newsDescriptionLabel.text = self.newsObjectData.newsDescription;
    self.newsDateLabel.text = self.newsObjectData.publicationDate;
    self.newsImageView.image = [UIImage imageWithData:self.newsObjectData.imageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    if([[segue identifier] isEqualToString:@"newsSourceSegue"])
    {
        //pass the data to the new view
        NewsSourceViewController* newsSourceViewController = segue.destinationViewController;
        
        //send the url to the destination view controller
        newsSourceViewController.webURL = self.newsObjectData.sourceURL;
    }
}

//displays the source URL
- (IBAction)pressedShowSourceButton:(UIButton *)sender
{
    //first, check for reachability to the url of the current source
    if([self.rchManager isConnectionAvailableTo:self.newsObjectData.sourceURL])
    {
        //show the source URL
        [self performSegueWithIdentifier:@"newsSourceSegue" sender:self];
    }
    else
    {
        //display an alert/error that no internet connectivity was found
        NSLog(@"Failed to connect to source url.");
    }
}




@end




