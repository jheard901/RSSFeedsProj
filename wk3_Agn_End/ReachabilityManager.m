//
//  ReachabilityManager.m
//  wk3_Agn_End
//
//  Created by User on 10/18/16.
//  Copyright © 2016 User. All rights reserved.
//

#import "ReachabilityManager.h"

@implementation ReachabilityManager


- (id)init
{
    self = [super init];
    if(self)
    {
        
        /*
         Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //set your internet reachability settings once
        [self startInternetReachability];
        
        //set the remote hostname later when request to a specific server is made
    }
    return self;
}

//this initialization auto sets up host reachability so you don't have to manually call that after a regular init
- (instancetype)initWithHostname:(NSString *)hostname
{
    self = [super init];
    if(self)
    {
        
        /*
         Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        //set your internet reachability settings once
        [self startInternetReachability];
        
        //set the remote hostname using a default address
        [self startRemoteReachability:hostname];
        
    }
    return self;
}


//check for connectivity to a specific domain through DNS
- (void)startRemoteReachability:(NSString*)hostname
{
    //Change the hostname to change the server you want to monitor.
    NSString *remoteHostName = hostname;
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
}

//update reachability to check with a different domain | run only after you have started remote reachability
- (void)updateRemoteReachability:(NSString*)hostname
{
    [self stopRemoteReachability];
    [self startRemoteReachability:hostname];
}

//this doesn't ever really need to be called...
- (void)stopRemoteReachability
{
    [self.hostReachability stopNotifier];
    [self updateInterfaceWithReachability:self.hostReachability];
}


//check for your device's connectivity to an ISP/network | run once at start
- (void)startInternetReachability
{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}

//only call this once after updateInternetReachability has been called - else encounter an exception
- (void)stopInternetReachability
{
    [self.internetReachability stopNotifier];
    [self updateInterfaceWithReachability:self.internetReachability];
}


/*!
 * Called by Reachability whenever status changes.
 */
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}


- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.hostReachability)
    {
        [self configureReachability:reachability];
        //NetworkStatus netStatus = [reachability currentReachabilityStatus];
        BOOL connectionRequired = [reachability connectionRequired];
        
        //int summaryInfo = (netStatus != ReachableViaWWAN);
        NSString* baseLabelText = @"";
        
        if (connectionRequired)
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is available.\nInternet traffic will be routed through it after a connection is established.", @"Reachability text if a connection is required");
        }
        else
        {
            baseLabelText = NSLocalizedString(@"Cellular data network is active.\nInternet traffic will be routed through it.", @"Reachability text if a connection is not required");
        }
        NSLog(@"%@", baseLabelText);
    }
    
    if (reachability == self.internetReachability)
    {
        [self configureReachability:reachability];
    }
    
}

//this is for displaying the output of changes in reachability
//this is what will perform actions based off the current status of reachability
- (void)configureReachability:(Reachability *)reachability
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    
    switch (netStatus)
    {
        //if unable to connect to a network
        case NotReachable:
        {
            //output some feedback to user?
            bCanConnect = NO;
            
            //Minor interface detail- connectionRequired may return YES even when the host is unreachable. We cover that up here...
            connectionRequired = NO;
            break;
        }
        //if able to connect to WWAN (ie 3G or 4G coverage)
        case ReachableViaWWAN:
        {
            //output some feedback to user?
            bCanConnect = YES;
            break;
        }
        //if able to connect to an ISP wirelessly
        case ReachableViaWiFi:
        {
            //output some feedback to the user?
            bCanConnect = YES;
            break;
        }
    }
    
    if (connectionRequired)
    {
        //output some feedback to user?
        NSLog(@"Connection Required.");
    }
}

//returns true if a connection is available to the specified website, otherwise is false
- (BOOL)isConnectionAvailableTo:(NSString*)webAddress
{
    [self updateRemoteReachability:webAddress];
    return bCanConnect;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}



@end






