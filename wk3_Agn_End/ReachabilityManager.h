//
//  ReachabilityManager.h
//  wk3_Agn_End
//
//  Created by User on 10/18/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"




@interface ReachabilityManager : NSObject
{
     BOOL bCanConnect;
}


@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;



- (id)init;
- (instancetype)initWithHostname:(NSString*)hostname;

- (void)startRemoteReachability:(NSString*)hostname;
- (void)updateRemoteReachability:(NSString*)hostname;
- (void)stopRemoteReachability;
- (void)startInternetReachability;
- (void)stopInternetReachability;

//these are private functions, so they are only defined in the .m file
//- (void)reachabilityChanged:(NSNotification *)note;
//- (void)updateInterfaceWithReachability:(Reachability *)reachability;
//- (void)configureReachability:(Reachability *)reachability;

- (BOOL)isConnectionAvailableTo:(NSString*)webAddress; //this is the primary function that this class will be used for
- (void)dealloc;

@end



