//
//  iTunesViewController.h
//  wk3_Agn_End
//
//  Created by User on 10/18/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>

//make a title for this called: "iTunes Top Albums"

@class iTunesCell;


@interface iTunesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    BOOL bPerformingQuery; //used for controlling threads usage in background when scrolling the view
    NSCache* appCache; //simple explanation on using cache: http://stackoverflow.com/questions/5755902/how-to-use-nscache
}



@property (nonatomic, strong) NSMutableArray* iTunesObjectsArray; //an array of iTunesObjects

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;




- (IBAction)changedSegmentSelection:(UISegmentedControl *)sender;
- (void)reloadVisibleCells;
- (void)downloadImageForCellAndReload:(iTunesCell*)tableCell;
- (void)downloadImageForCell:(iTunesCell*)tableCell;


@end




