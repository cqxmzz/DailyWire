//
//  WebViewController.h
//  DailyWire
//
//  Created by Qiming Chen on 1/31/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import <SafariServices/SFAuthenticationSession.h>
#import <OneSignal/OneSignal.h>

@interface WebViewController : UIViewController <WKNavigationDelegate, WKUIDelegate> {
    NSDate *startDate;
    UIRefreshControl *refreshControl;
    WKProcessPool *processPool;
    WKBackForwardListItem *lastItem;
    @public SFSafariViewController *sfvc;
    @public SFAuthenticationSession *sfac;
}

-(void) handleNavigate:(NSString *) link;

@end

