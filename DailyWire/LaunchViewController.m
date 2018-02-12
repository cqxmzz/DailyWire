//
//  LaunchViewController.h
//  DailyWire
//
//  Created by Qiming Chen on 2/08/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import "LaunchViewController.h"

@interface LaunchViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *launchImageView;

@end

@implementation LaunchViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    webViewController = appDelegate->webViewController;
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"hasShowedIntro"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [webViewController.view setNeedsLayout];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            IntroViewController *introViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
            introViewController->webViewController = webViewController;
            [NSThread sleepForTimeInterval:2.0f];
            [self presentViewController:introViewController animated:YES completion:nil];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [webViewController.view setNeedsLayout];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1.5f];
            [self presentViewController:webViewController animated:YES completion:nil];
        });
    }
}



@end

