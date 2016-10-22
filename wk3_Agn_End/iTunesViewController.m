//
//  iTunesViewController.m
//  wk3_Agn_End
//
//  Created by User on 10/18/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "iTunesViewController.h"
#import "iTunesSourceViewController.h"
#import "iTunesCell.h"
#import "iTunesObject.h"

#import "ReachabilityManager.h"


#define iTunesAlbumsLimit @"150" //largest number allowed is 200
#define iTunesAlbumsURL [NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/limit=%@/json", iTunesAlbumsLimit]
//#define iTunesAlbumsURL @"https://itunes.apple.com/us/rss/topalbums/limit=15/json"




@interface iTunesViewController ()

@property (nonatomic, strong) ReachabilityManager* iReachManager;

@end





@implementation iTunesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    bPerformingQuery = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.iTunesObjectsArray = [[NSMutableArray alloc] init];
    
    //setup reachability manager
    self.iReachManager = [[ReachabilityManager alloc] initWithHostname:@"www.google.com"];
    
    //setup app cache (note: it resets each time app restarts)
    appCache = [[NSCache alloc] init];
    
    //create a session
    NSURL* dataURL = [NSURL URLWithString:iTunesAlbumsURL];
    NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:dataURL completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        
        /* this completion handler is run after the downloadTask has finished */
        
        NSDictionary* dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error]; //this holds all the data obtained from the itunes url | 0 can also be used for options
        
        //following this tut for iTunes specifically here: https://www.youtube.com/watch?v=9MEnvlqP-wU
        //at '7:30' in the video is where the main gist of what you need to know starts: https://youtu.be/9MEnvlqP-wU?t=452
        //because the data is nested we need to create another dictionary to access the data
        NSDictionary* feed = [dataDictionary objectForKey:@"feed"];
        NSArray* arrayOfEntry = [feed objectForKey:@"entry"]; //use an array here, because these elements are shown as array in the .json (use a json viewer online to properly see the data: http://codebeautify.org/jsonviewer# )
        
        //iterate through each element of the array (this for loop can also be used with dictionarys)
        for(NSDictionary* diction in arrayOfEntry)
        {
            //grab the album name for each one
            NSDictionary* name = [diction objectForKey:@"im:name"];
            NSString* albumNameLabel = [name objectForKey:@"label"];
            
            //grab the genre for each one
            NSDictionary* category = [diction objectForKey:@"category"];
            NSDictionary* categoryAttributes = [category objectForKey:@"attributes"];
            NSString* genreNameLabel = [categoryAttributes objectForKey:@"label"];
            
            //grab the artist for each one
            NSDictionary* artist = [diction objectForKey:@"im:artist"];
            NSString* artistNameLabel = [artist objectForKey:@"label"];
            
            //grab the price for each one
            NSDictionary* price = [diction objectForKey:@"im:price"];
            NSString* priceLabel = [price objectForKey:@"label"];
            
            //grab the release date for each one
            NSDictionary* releaseDate = [diction objectForKey:@"im:releaseDate"];
            NSDictionary* releaseAttributes = [releaseDate objectForKey:@"attributes"];
            NSString* dateLabel = [releaseAttributes objectForKey:@"label"];
            
            //grab the album image URL for each one
            NSArray* albumImage = [diction objectForKey:@"im:image"];
            NSDictionary* albumImageSize = [albumImage objectAtIndex:2]; //default to 3rd element (3 diff sizes available)
            NSString* albumImageURL = [albumImageSize objectForKey:@"label"];
            
            //grab the album source URL for each one
            NSDictionary* link = [diction objectForKey:@"link"];
            NSDictionary* linkAttributes = [link objectForKey:@"attributes"];
            NSString* albumSourceURL = [linkAttributes objectForKey:@"href"];
            
            
            //now create an object to hold all this data we have harvested, and then add that object to the table's dataSource (ie objectHolderArray)
            iTunesObject* accessedObject = [[iTunesObject alloc]
                                            initWithAlbum:albumNameLabel
                                            Genre:genreNameLabel
                                            Artist:artistNameLabel
                                            Price:priceLabel
                                            ReleaseDate:dateLabel
                                            AlbumImageURL:albumImageURL
                                            AlbumSourceURL:albumSourceURL];
            [self.iTunesObjectsArray addObject:accessedObject];
        }
        
        
        //reload table with this data in the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
        
    }];
    
    /* all tasks from NSURLSession start in a suspended state; start the task here */
    
    //check if the web address is reachable
    if([self.iReachManager isConnectionAvailableTo:iTunesAlbumsURL])
    {
        NSLog(@"Successfully connected to the iTunes Top Albums RSS Feed");
        
        //perform task in a background thread | info: http://stackoverflow.com/questions/16283652/understanding-dispatch-async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [downloadTask resume];
        });
    }
    else
    {
        NSLog(@"Failed to connect to the RSS feed. Reload view with an active connection to refresh.");
    }
}



#pragma mark - Table stuff


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.iTunesObjectsArray count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //will return a string with "top [number of items in list]"
    return [NSString stringWithFormat:@"Top %@", iTunesAlbumsLimit];
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"iTunesCell";
    iTunesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    /* configure the cell based off the current segment selected */
    
    //we'll assume this is needed by each cell... so let's put it here.
    cell.albumImageView.image = nil;
    
    //get a reference to current object from array
    iTunesObject* currentObject = [self.iTunesObjectsArray objectAtIndex:indexPath.row];
    
#warning Not sure if this is actually loading images as user scrolls, I've seen images pop in while scrolling and also images already downloaded when scrolling
    
    //When 'All' is selected
    if(self.segmentControl.selectedSegmentIndex == 0)
    {
        //temporarily using this as defaults for testing
        cell.albumLabel.text = currentObject.album;
        cell.genreLabel.text = currentObject.genre;
        cell.artistLabel.text = currentObject.artist;
        cell.priceLabel.text = currentObject.price;
        cell.dateLabel.text = currentObject.date;
        
        
        //to load the correct image: http://stackoverflow.com/questions/16663618/async-image-loading-from-url-inside-a-uitableview-cell-image-changes-to-wrong
        
        NSString* imageurl = ((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).imageURL;
        NSURL* imgURL = [NSURL URLWithString:imageurl];
        //NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
        //maybe this should fire off a selector using imageData as the reference to pass through it to notify the cell it should update to this image?
        //tableCell.albumImageView.image = [UIImage imageWithData:imageData];
        //tableCell.bLoadingImage = NO;
        
        
        //check if this image is already within cache
        if([appCache objectForKey:imgURL])
        {
            //load data from cache
            NSData* imgData = [appCache objectForKey:imgURL];
            UIImage* img = [UIImage imageWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^ { cell.albumImageView.image = img; });
        }
        else
        {
            //using a background thread here appears to work about as well as using it when only surrounding the "[downloadTask resume];"
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:imgURL completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                    
                    if(data)
                    {
                        //store the image data into cache for future usage
                        [appCache setObject:data forKey:imgURL];
                        
                        UIImage* image = [UIImage imageWithData:data];
                        if(image)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                //update cell to utilize image
                                iTunesCell* updatedCell = [self.tableView cellForRowAtIndexPath:indexPath];
                                if(updatedCell)
                                {
                                    updatedCell.albumImageView.image = image;
                                }
                            });
                        }
                    }
                    
                }];
                
                [downloadTask resume];
            });
        }
        
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [downloadTask resume]; });
    }
    //When 'Text' is selected
    else if(self.segmentControl.selectedSegmentIndex == 1)
    {
        cell.albumLabel.text = currentObject.album;
        cell.genreLabel.text = currentObject.genre;
        cell.artistLabel.text = currentObject.artist;
        cell.priceLabel.text = currentObject.price;
        cell.dateLabel.text = currentObject.date;
        //cell.albumImageView.image = nil; //probably not the best way to go, but it works for now
    }
    //When 'Images' is selected
    else
    {
        cell.albumLabel.text = @"";
        cell.genreLabel.text = @"";
        cell.artistLabel.text = @"";
        cell.priceLabel.text = @"";
        cell.dateLabel.text = @"";
        
        NSString* imageurl = ((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).imageURL;
        NSURL* imgURL = [NSURL URLWithString:imageurl];
        
        //check if this image is already within cache
        if([appCache objectForKey:imgURL])
        {
            //load data from cache
            NSData* imgData = [appCache objectForKey:imgURL];
            UIImage* img = [UIImage imageWithData:imgData];
            dispatch_async(dispatch_get_main_queue(), ^ { cell.albumImageView.image = img; });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSURLSessionDataTask* downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:imgURL completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
                    
                    if(data)
                    {
                        //store the image data into cache for future usage
                        [appCache setObject:data forKey:imgURL];
                        
                        UIImage* image = [UIImage imageWithData:data];
                        if(image)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                iTunesCell* updatedCell = [self.tableView cellForRowAtIndexPath:indexPath];
                                if(updatedCell)
                                {
                                    updatedCell.albumImageView.image = image;
                                }
                            });
                        }
                    }
                }];
                
                [downloadTask resume];
            });
        }
    }
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //reachability checks if the URL for the selected cell is valid
    if([self.iReachManager isConnectionAvailableTo:((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).sourceURL])
    {
        //it seems the iTunes url will not open if the cell has not populated with its image...
        [self performSegueWithIdentifier:@"iTunesSourceSegue" sender:self];
    }
    else
    {
        NSLog(@"Failed to connect to the external URL.");
    }
    
}

//nope.jpg
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //the last try
    //iTunesCell* currentCell;
    
    //for (currentCell in [self.tableView visibleCells])
    //{
        //reload that individual cell
        //NSIndexPath* indexPath = [self.tableView indexPathForCell:currentCell];
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //}
    
    
    /*
    
    
    
    
    //get the current visible cells from table and load the images for them in the background | info from: http://stackoverflow.com/questions/9094089/how-to-detect-how-many-cells-are-visible-in-a-uitableview
    
    //control how often this query is performed (since it is called so many times
    if(!bPerformingQuery)
    {
        bPerformingQuery = YES;
        //queryCount = 0;
        //const NSInteger queryTotal = [[self.tableView visibleCells] count];
        
        
        
        for(int i = 0; i < [[self.tableView visibleCells] count]; i++)
        {
            iTunesCell* currentCell = (iTunesCell*)[[self.tableView visibleCells] objectAtIndex:i];
            
            //reload that individual cell
            //NSIndexPath* indexPath = [self.tableView indexPathForCell:currentCell];
            //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            
            
            //check each visible cell to see if its image is nil
            if(currentCell.albumImageView.image == nil && !currentCell.bLoadingImage)
            {
                //perform a download session in the background to download the URL
                //on completion it should add the image to the cell in the main thread
                
                //get a reference to the iTunesObject for this cell | perform in background thread
                //[self performSelectorInBackground:@selector(<#selector#>) withObject:<#(nullable id)#>]; //this is an option
                
                currentCell.bLoadingImage = YES;
                
                //trying to figure this out (loading the correct image to its album, but it seems problem is related to cell not being set to nil before returning it), but will have to return later: http://stackoverflow.com/questions/16663618/async-image-loading-from-url-inside-a-uitableview-cell-image-changes-to-wrong and more: http://stackoverflow.com/questions/14400378/ios-lazy-loading-of-table-images and even more: http://stackoverflow.com/questions/4448321/is-it-possible-to-refresh-a-single-uitableviewcell-in-a-uitableview and for reference: http://stackoverflow.com/questions/9094089/how-to-detect-how-many-cells-are-visible-in-a-uitableview and for more reference: http://stackoverflow.com/questions/16283652/understanding-dispatch-async
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    
                    //because background threads do not wait for current query to finish, we need to manually track the cell in thread
                    //iTunesCell* trackedCell = currentCell;
                
                    //return the dispatch to be as before, this time, try using a function to take in a reference of the cell and execute downloading the image in a background thread
                    currentCell.albumImageView.image = nil;
                    
                    [self downloadImageForCellAndReload:currentCell];
                    
                    / * connect this latah
                    //perform in background
                    NSIndexPath* indexPath = [self.tableView indexPathForCell:currentCell];
                    NSString* imageurl = ((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).imageURL;
                    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
                    currentCell.albumImageView.image = [UIImage imageWithData:imageData]; //maybe this line should be in the main thread?
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //perform in main thread and then reload table
                        //currentCell.albumImageView.image = [UIImage imageWithData:imageData];
                        
                        [self.tableView reloadData];
                        //new reload method from: http://stackoverflow.com/questions/4448321/is-it-possible-to-refresh-a-single-uitableviewcell-in-a-uitableview
                        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                        
                        //once all the background threads have caught up, then we can take new requests
                        //queryCount++;
                        //if(queryCount == queryTotal)
                        //{
                            //reset for next query check
                            //bPerformingQuery = NO;
                        //}
                        
                    });
                    // * / //connect this latah
                });
                
            }
            
            
            
        }
        
        
        //reset for next check
        bPerformingQuery = NO;
    }
    
    
    
    */
}


//triggers when user starts to begin dragging the scroll view
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //[self reloadVisibleCells];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"iTunesSourceSegue"])
    {
        //pass the url for the album source of the currently selected cell to the web view in destination controller
        iTunesSourceViewController* itunesSourceViewController = (iTunesSourceViewController*)segue.destinationViewController;
        
        //get a reference to the selected cell and send its associated iTunesObject url to the destination controller
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        
        //format a URL specifically for iTunes | info:http://stackoverflow.com/questions/818973/how-can-i-link-to-my-app-in-the-app-store-itunes
        //removing whitespaces: http://stackoverflow.com/questions/7628470/remove-all-whitespaces-from-nsstring
        iTunesObject* currentObject = (iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row];
        NSString* artistFN = [currentObject.artist stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* albumFN = [currentObject.album stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* iTunesURL = [NSString stringWithFormat:@"http://itunes.com/%@/%@", artistFN, albumFN];
        
#warning Sending the sourceURL is fine too, but the iTunesURL opens it up in iTunes App
        //itunesSourceViewController.webURL = currentObject.sourceURL;
        itunesSourceViewController.webURL = iTunesURL;
    }
    
}



- (IBAction)changedSegmentSelection:(UISegmentedControl *)sender
{
    //this should reload the table in the main thread with async
    [self reloadVisibleCells];
}


- (void)reloadVisibleCells
{
    //the last try
    iTunesCell* currentCell;
    
    //reload these individual cells
    for (currentCell in [self.tableView visibleCells])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForCell:currentCell];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//nope.jpg
- (void)downloadImageForCellAndReload:(iTunesCell *)tableCell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:tableCell];
    NSString* imageurl = ((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).imageURL;
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
    //maybe this should fire off a selector using imageData as the reference to pass through it to notify the cell it should update to this image?
    tableCell.albumImageView.image = [UIImage imageWithData:imageData];
    tableCell.bLoadingImage = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //perform in main thread and then reload table
        //currentCell.albumImageView.image = [UIImage imageWithData:imageData];
        
        [self.tableView reloadData]; //this works better and it seems to affect which album images are loaded
        
        //new reload method from: http://stackoverflow.com/questions/4448321/is-it-possible-to-refresh-a-single-uitableviewcell-in-a-uitableview
        //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
    });
}

//nope.jpg
- (void)downloadImageForCell:(iTunesCell *)tableCell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:tableCell];
    NSString* imageurl = ((iTunesObject*)[self.iTunesObjectsArray objectAtIndex:indexPath.row]).imageURL;
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageurl]];
    //maybe this should fire off a selector using imageData as the reference to pass through it to notify the cell it should update to this image?
    tableCell.albumImageView.image = [UIImage imageWithData:imageData];
    tableCell.bLoadingImage = NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end






