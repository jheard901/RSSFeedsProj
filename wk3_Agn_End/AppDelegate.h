//
//  AppDelegate.h
//  wk3_Agn_End
//
//  Created by User on 10/14/16.
//  Copyright © 2016 User. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//for setting up xcode to test your apps without paying the $99 Apple Developer fee: http://stackoverflow.com/questions/30727099/how-to-run-apps-on-iphone-ipad-using-xcode-7-without-enrolling-to-apples-develo

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

