//
//  AppDelegate.h
//  DailyWire
//
//  Created by Qiming Chen on 1/31/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    @public WebViewController *webViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end

