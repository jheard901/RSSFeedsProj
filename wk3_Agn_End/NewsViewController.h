//
//  NewsViewController.h
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCell.h"




@interface NewsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, NewsCellDelegate>

@property (strong, nonatomic) NSXMLParser* parser;
@property (strong, nonatomic) NSString* currentElement; //used for navigating a parsed xml file
@property (assign, nonatomic) NSInteger* currentDepth;
@property (strong, nonatomic) NSString* elementNest;


@property (nonatomic, strong) NSMutableArray* newsObjectArray;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;


- (IBAction)changedSegmentSelection:(UISegmentedControl *)sender;


@end


