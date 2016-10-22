//
//  NewsViewController.m
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//



#import "NewsViewController.h"
#import "NewsObject.h"
#import "NewsDetailViewController.h"

#import "TFHpple.h"
#import "NSString+HTML.h"
#import "DBManager.h"
#import "ReachabilityManager.h"




//the URL string where we get xml formatted information from
#define dataFeedURL @"https://news.google.com/news/section?ned=us&topic=h&output=rss"


@interface NewsViewController ()

//private variables
@property (nonatomic, strong) DBManager* dbManager;
@property (nonatomic, strong) ReachabilityManager* reachManager;

@end




//going to stick this up here so it can be seen and read by me later. Discovered Doxygen comments can be made as indicated here: http://stackoverflow.com/questions/18292155/how-to-include-doxygen-method-description-in-xcodes-autocomplete-popup
//however, I discovered this exists because I had a comment below with "//<tr>" which popped up a warning about it not being a doxygen trailing comment




@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.newsObjectArray = [[NSMutableArray alloc] init];
    
    //setup reachability manager
    self.reachManager = [[ReachabilityManager alloc] initWithHostname:@"www.google.com"]; //google :)
    
    //setup db manager and attempt loading any saved articles
    self.dbManager = [[DBManager alloc] initWithFilename:@"_articlesB.db"]; //"articles.db, _articles.db" need to be deleted (because it is using old table format of 5 cols, and 7 cols | current format is 7 cols with proper description and image source), but I can't find it on disk :/ | current db: "_articlesB.db"
    [self.dbManager loadAllNewsObjects];
    
    
    
    //NSURLSession tut: https://www.raywenderlich.com/67081/cookbook-using-nsurlsession
    //create a session
    NSURL* dataURL = [NSURL URLWithString:dataFeedURL];
    NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:dataURL completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
       
        /* handle the response here (this area is the completionHandler) */
        
        //xml parsing with TFHpple | info from: https://www.raywenderlich.com/14172/how-to-parse-html-on-ios
        TFHpple* tfhppleParser = [TFHpple hppleWithXMLData:data];
        
        //to properly interpret the data for parsing, use an xml viewer: http://codebeautify.org/xmlviewer#
        //used for specifically getting elements from the tree that fall within this nest structure
        NSString* XpathQueryString = @"//channel/item";
        NSArray* itemNodes = [tfhppleParser searchWithXPathQuery:XpathQueryString];
        
        //I think this will fix the problems with threads...
        dispatch_async(dispatch_get_main_queue(), ^{
        
        //harvest the gathered data from tfhpple parser and store it in an array of newsObjects
        for(TFHppleElement* nElement in itemNodes)
        {
            NSString* title = [[nElement firstChildWithTagName:@"title"] content];
            NSString* source = [[nElement firstChildWithTagName:@"link"] content];
            NSString* date = [[nElement firstChildWithTagName:@"pubDate"] content];
            
            
            ////////////parsing the image and description from table////////////
            
            NSString* tableContent = [[nElement firstChildWithTagName:@"description"] content];
            
            //parsing a string: http://stackoverflow.com/questions/938586/how-to-parse-strings-in-objective-c
            //in the future, we could use MWFeedParser to better parse the HTML table
            
            //obtains image from table | this code is subject to change based off any changes Google's RSS News Feed makes to their web source
            NSArray *components = [tableContent componentsSeparatedByString:@"<img src=\"//"]; //for some reason, always need to skip 1st element
            NSString *afterOpenBracket = [components objectAtIndex:1];
            components = [afterOpenBracket componentsSeparatedByString:@"\""];
            NSString *img = [components objectAtIndex:0];
            //filter the img string of invalid characters not in ASCII set: http://stackoverflow.com/questions/28267557/unsupported-url-ios
            NSString* imgFiltered = [img stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            //format with protocol prefix: http://stackoverflow.com/questions/20294328/unsupported-url-in-nsurlrequest
            NSString* imgFormatted = [NSString stringWithFormat:@"http://%@", imgFiltered];
            
            //obtains description from table | this code is subject to change based off any changes Google's RSS News Feed makes to their web source
            NSArray *componentsB = [tableContent componentsSeparatedByString:@"<font size=\"-1\">"];
            NSString *afterOpenBracketB = [componentsB objectAtIndex:2];
            componentsB = [afterOpenBracketB componentsSeparatedByString:@"</font>"];
            NSString *content = [componentsB objectAtIndex:0];
            NSString* contentFiltered = [content stringByConvertingHTMLToPlainText]; //from MWFeedParser -> NSString+HTML.h
            
            ////////////parsing the image and description from table////////////
            
            
            NewsObject* newsObject = [[NewsObject alloc] initWithAllTitle:title SourceURL:source PublicationDate:date NewsDescription:contentFiltered ImageURL:imgFormatted];
            [self.newsObjectArray addObject:newsObject];
        }
        
        
            [self.tableView reloadData];
        });
        
    }];
    
    /* all tasks from NSURLSession start in a suspended state; start the task here */
    
    //check if the web address is reachable
    if([self.reachManager isConnectionAvailableTo:dataFeedURL])
    {
        NSLog(@"Successfully connected to the dataFeedURL");
        [downloadTask resume];
    }
    else
    {
        NSLog(@"Failed to connect to the dataFeedURL. Reload view with an active connection to refresh.");
    }
    
    
}


#pragma mark - XML Parsing

//IMPORTANT: Use the XPath .lib from the tutorial for parsing xml, no point in trying to reinvent the wheel when you have so little time to do the assignment

//this method did not work out as intended (i.e. _parser.columnNumber jumped to the 10,000's when I only expected it to be about 4 level at most)... it is not utilized in this program
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    
    if((int)self.currentDepth != self.parser.columnNumber)
    {
        self.currentDepth = (NSInteger*)self.parser.columnNumber;
        //change the elementNest to reflect which nest we just went down
        self.elementNest = elementName;
        
        //debug output
        NSLog(@"Previous Nest: %@ | Current Nest: %@ | Col. Num: %ld", self.currentElement, self.elementNest, (long)self.parser.columnNumber);
    }
    
    //this method function is old, and not being utilized... I think.
    if([elementName isEqualToString:@"channel"])
    {
        
    }
    if ([elementName isEqualToString:@"item"])
    {
        
    }
    self.currentElement = elementName;
}

//this method did not work out as intended... it is not utilized in this program
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //this returns the output of every single title element (nested & unnested), but I only want it to get the elements of nested ones under the element @"item"
    if([self.currentElement isEqualToString:@"title"])
    {
        //NSLog(@"Current value: %@", string);
    }
    //tip from: http://stackoverflow.com/questions/2005448/how-to-use-nsxmlparser-to-parse-parent-child-elements-that-have-the-same-name
    if(self.parser.columnNumber > 2) //at column 3 level 3, we are at least inside the 'item' element
    {
        if([self.currentElement isEqualToString:@"title"])
        {
            //NSLog(@"Current value: %@", string);
        }
        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    self.currentElement = @"";
}

#pragma mark - Table Controller Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//number of rows depends on which segment is selected
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.segmentControl selectedSegmentIndex] == 0)
    {
        return [self.newsObjectArray count];
    }
    else
    {
        return [self.dbManager.arrResults count];
    }
    
}

//depending on the value of segmentControl we decide whether to put "Latest News" or "Saved News" as the header
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if([self.segmentControl selectedSegmentIndex] == 0) //latest articles selected
    {
        return @"Latest News Articles";
    }
    else if([self.segmentControl selectedSegmentIndex] == 1) //saved articles selected
    {
        return @"Archived News Articles";
    }
    else //default title
    {
        return @"Latest News Articles";
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"NewsCell";
    NewsCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    /* current cell value depends on selected segment */
    
    //used for setting image of the favorites button on cells
    UIImage* unselectedImage = [UIImage imageNamed:@"grayOutlineStar"];
    UIImage* selectedImage = [UIImage imageNamed:@"boldYellowStar"];
    
    //latest articles
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
        NewsObject* currentObject = [self.newsObjectArray objectAtIndex:indexPath.row];
        
        //configure the custom cell here
        cell.titleLabel.text = currentObject.title;
        cell.descriptionLabel.text = currentObject.newsDescription;
        
        cell.delegate = self;
        
        //we need to check if this cell is stored within the SQL db; if so, then it should have it's button changed to selected
        //to do this comparision, we will compare the title text from currentObject.title to every saved value in the SQL database (ik, it sounds like a slow operation, but that is the only way to pull it off). SO, DBManager needs a - (bool) function that takes in a (NSString*)newsTitle as a parameter then goes through every row, comparing only the 1 element with the string to see if its a match; if one is found, then it should break out the loop and return YES for finding the article and change the star (favorites button) of that cell accordingly.
        if([self.dbManager isArticleInDB:currentObject.title])
        {
            [cell.favoritesButton setImage:selectedImage forState:UIControlStateSelected];
            [cell.favoritesButton setSelected:YES];
        }
        else
        {
            [cell.favoritesButton setImage:unselectedImage forState:UIControlStateSelected];
            [cell.favoritesButton setSelected:NO];
        }
        
        return cell;
    }
    //saved articles
    else
    {
        NewsObject* currentObject = [self.dbManager.arrResults objectAtIndex:indexPath.row];
        
        //configure the custom cell here
        cell.titleLabel.text = currentObject.title;
        cell.descriptionLabel.text = currentObject.sourceURL;
        
        cell.delegate = self;
        
        //every cell should be true here, since they are saved articles
        if([self.dbManager isArticleInDB:currentObject.title])
        {
            [cell.favoritesButton setImage:selectedImage forState:UIControlStateSelected];
            [cell.favoritesButton setSelected:YES];
        }
        else
        {
            [cell.favoritesButton setImage:unselectedImage forState:UIControlStateSelected];
            [cell.favoritesButton setSelected:NO];
        }
        
        return cell;
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"newsDetailSegue" sender:self];
}


//received call from cell notifying that its favorites button was pressed
- (void) newsCellPressedFavorites:(NewsCell *)newsCell
{
    //simple test for toggling button image | info: http://stackoverflow.com/questions/1072698/changing-image-on-uibutton-when-user-presses-that-button-on-an-iphone
    
    UIImage* unselectedImage = [UIImage imageNamed:@"grayOutlineStar"];
    UIImage* selectedImage = [UIImage imageNamed:@"boldYellowStar"];
    
    if([newsCell.favoritesButton isSelected])
    {
        [newsCell.favoritesButton setImage:unselectedImage forState:UIControlStateNormal];
        [newsCell.favoritesButton setSelected:NO];
        
        /* remove the article associated with this cell from db */
        
        //get indexPath to this specific cell | info from: http://stackoverflow.com/questions/13723785/get-row-index-of-custom-cell-in-uitableview
        NSIndexPath* indexPath = [self.tableView indexPathForCell:newsCell];
        
        /* remove the specified article from SQL db */
        
        //reference latest articles list
        if(self.segmentControl.selectedSegmentIndex == 0)
        {
            [self.dbManager deleteNewsObjectTitled:((NewsObject*)[self.newsObjectArray objectAtIndex:indexPath.row]).title];
        }
        //reference the saved articles list
        else
        {
            [self.dbManager deleteNewsObjectTitled:((NewsObject*)[self.dbManager.arrResults objectAtIndex:indexPath.row]).title];
        }
    }
    else
    {
        [newsCell.favoritesButton setImage:selectedImage forState:UIControlStateSelected];
        [newsCell.favoritesButton setSelected:YES];
        
        /* add article associated with this cell to db */
        
        //get indexPath to this specific cell | info from: http://stackoverflow.com/questions/13723785/get-row-index-of-custom-cell-in-uitableview
        NSIndexPath* indexPath = [self.tableView indexPathForCell:newsCell];
        
        /* use it to get the relative newsObject from newsObjectsArray and save it to the SQL db */
        
        //reference latest articles list
        if(self.segmentControl.selectedSegmentIndex == 0)
        {
            [self.dbManager saveNewsObject:[self.newsObjectArray objectAtIndex:indexPath.row]];
        }
        //reference saved articles list
        else
        {
            [self.dbManager saveNewsObject:[self.dbManager.arrResults objectAtIndex:indexPath.row]];
        }
        
        //note, the object will not immediately show up; it needs to be loaded into the arrResults used by dbManager through calling "loadAllNewsObjects". So, we can use this function each time an item is added, or only perform it whenever the selection segment is switched over to the saved articles - yep, that sounds like the plan.
    }
    
}


#pragma mark - UI Button Interactions

- (IBAction)changedSegmentSelection:(UISegmentedControl *)sender
{
    //reload the table when changing the segment selected to show the correct list for saved articles
    if(self.segmentControl.selectedSegmentIndex == 1)
    {
        //only reload db when changing to saved articles
        [self.dbManager loadAllNewsObjects];
    }
    
    [self.tableView reloadData];
}





 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"newsDetailSegue"])
    {
        //pass the data to the new view
        NewsDetailViewController* newsDetailViewController = segue.destinationViewController;
        
        /* send the selected row's data to the destination view controller */
        
        //if viewing latest articles
        if(self.segmentControl.selectedSegmentIndex == 0)
        {
            NSIndexPath* nRowPath = [self.tableView indexPathForSelectedRow];
            newsDetailViewController.newsObjectData = [self.newsObjectArray objectAtIndex:nRowPath.row];
        }
        //if viewing saved articles
        else
        {
            NSIndexPath* nRowPath = [self.tableView indexPathForSelectedRow];
            newsDetailViewController.newsObjectData = [self.dbManager.arrResults objectAtIndex:nRowPath.row];
        }
        
        newsDetailViewController.rchManager = _reachManager;
    }
}



#pragma mark - On Application End

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}



@end






