//
//  AppDelegate.m
//  DailyWire
//
//  Created by Qiming Chen on 1/31/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import "AppDelegate.h"

#import <OneSignal/OneSignal.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    webViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    id notificationOpenedBlock = ^(OSNotificationOpenedResult *result) {
        NSString *url = result.notification.payload.rawPayload[@"custom"][@"a"][@"url"];
        [webViewController.view setNeedsLayout];
        [webViewController handleNavigate:url];
    };
    
    [OneSignal initWithLaunchOptions:launchOptions
                               appId:@"f3d65f86-40a9-4943-b76c-ddf547e983cd"
            handleNotificationAction:notificationOpenedBlock
                            settings:@{kOSSettingsKeyAutoPrompt: @false}];
    OneSignal.inFocusDisplayType = OSNotificationDisplayTypeNotification;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    [webViewController->sfvc dismissViewControllerAnimated:false completion:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
