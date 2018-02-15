//
//  LaunchViewController.h
//  DailyWire
//
//  Created by Qiming Chen on 2/08/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import "LaunchViewController.h"
#import "IntroViewController.h"

@interface IntroViewController ()

@property (strong, nonatomic) IBOutlet UIButton *buttonView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation IntroViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Intro
    [self.buttonView addTarget:self action:@selector(introButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

// Intro Button Click
-(void)introButtonAction {
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"hasShowedIntro"];
    UIWindow *window = [self.view window];
    [window setRootViewController:webViewController];
}

@end

