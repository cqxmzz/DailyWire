//
//  SettingsViewController.h
//  DailyWire
//
//  Created by Qiming Chen on 2/08/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation SettingsViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Intro
    [self.doneButton setAction:@selector(doneButtonAction)];
}

// Intro Button Click
-(void)doneButtonAction {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

