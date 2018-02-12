//
//  WebViewController.h
//  DailyWire
//
//  Created by Qiming Chen on 1/31/18.
//  Copyright © 2018 Qiming Chen. All rights reserved.
//

#import "WebViewController.h"
#import "LaunchViewController.h"
#import "SettingsViewController.h"

@interface WebViewController ()

@property (strong, nonatomic) IBOutlet WKWebView *webView;
@property (strong, nonatomic) IBOutlet UIProgressView *progView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webTop;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *webTopNew;

@end

@implementation WebViewController

// App view load
-(void)viewDidLoad {
    [super viewDidLoad];
    [self initWeb];
}

-(void)viewDidAppear:(BOOL)animated {
    [OneSignal promptForPushNotificationsWithUserResponse:^(BOOL accepted) {}];
}

-(void)initWeb {
    startDate = [NSDate date];
    // Progress Bar
    self.progView.trackTintColor = UIColor.whiteColor;
    // Settings
    self.webView.configuration.processPool = processPool;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.allowsBackForwardNavigationGestures = true;
    self.webView.allowsLinkPreview = false;
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    // Progress
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:NSKeyValueObservingOptionNew context:NULL];
    // Request
    [self handleNavigate:@"https://www.dailywire.com"];
    [self.backButton setAction:@selector(backButtonAction)];
}

// Back Button Click
-(void)backButtonAction {
    [self.webView goToBackForwardListItem:lastItem];
}

// Web refresh
-(void)handleRefresh:(UIRefreshControl *)refresh {
    [self.webView reload];
    [refresh endRefreshing];
}

// Web navigation
-(void)handleNavigate:(NSString *)link {
    NSURL *url = [NSURL URLWithString:link];
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:nsrequest];
}

// Navigation bar
-(void)navigateBar:(BOOL)show {
    [self.navigationBar setHidden:!show];
    [self.webTop setActive:!show];
    [self.webTopNew setActive:show];
    [self updateViewConstraints];
}

-(void)handleNavigateBar:(nonnull WKNavigationAction *)navigationAction {
    NSURL* oldUrl = self.webView.URL;
    NSURL* url = navigationAction.request.URL;
    if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com/next/login/"] ||
        [[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com/_ax/"]) {
        [self navigateBar:YES];
    } else if ([[NSString stringWithFormat:@"%@", oldUrl] hasPrefix: @"https://www.dailywire.com/"]) {
        [self navigateBar:NO];
    } else if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://www.dailywire.com/"]) {
        [self navigateBar:NO];
    }
    
}

// SafariView
-(void)safariView:(NSURL *)url {
    sfvc = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:sfvc animated:YES completion:nil];
}

// IOS open application
-(void)applicationOpen:(NSURL *)url {
    UIApplication *app = [UIApplication sharedApplication];
    if ([app canOpenURL:url]) {
        [app openURL:url options:@{}.mutableCopy completionHandler:nil];
    }
}

// Last dailywire page
-(void)recordLastState {
    if ([[NSString stringWithFormat:@"%@", self.webView.URL] hasPrefix: @"https://www.dailywire.com/"]) {
        lastItem = [self.webView.backForwardList itemAtIndex:0];
    }
}

// Handle web navigation
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL* url = navigationAction.request.URL;
    // NSLog(@"## Outside: %@", url);
    [self recordLastState];
    [self handleNavigateBar:navigationAction];
    if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://www.dailywire.com/"]) {
        if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://www.dailywire.com/app/settings"]) {
            NSLog(@"settings clicked");
            SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
            settingsViewController->webViewController = self;
            [self presentViewController:settingsViewController animated:YES completion:nil];
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    } else if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com"]) {
        // disqus.com
        decisionHandler(WKNavigationActionPolicyAllow);
        if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com/next/login-success/#!auth%3Asuccess"]) {
            [self.webView goToBackForwardListItem:lastItem];
        }
    } else if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"http"] &&
               (navigationAction.navigationType == UIWebViewNavigationTypeLinkClicked ||
                navigationAction.navigationType == UIWebViewNavigationTypeOther)) {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self safariView:url];
    } else if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"mailto:"] ||
               [[NSString stringWithFormat:@"%@", url] hasPrefix: @"tel:"]) {
        // IOS action
        [self applicationOpen:url];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

// Handle new page
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    [self recordLastState];
    if (!navigationAction.targetFrame.isMainFrame) {
        NSURL *url = navigationAction.request.URL;
        if ([[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com/next/login"] ||
            [[NSString stringWithFormat:@"%@", url] hasPrefix: @"https://disqus.com/_ax"]) {
            [self handleNavigate:url.absoluteString];
        } else {
            [self safariView:url];
        }
    }
    return nil;
}

// Web fix and changes
- (void)webChanges {
    if (![[NSString stringWithFormat:@"%@", self.webView.URL] hasPrefix: @"https://www.dailywire.com/"]) {
        return;
    }
    NSString *js =
        @"var style = document.createElement('style');\
            style.innerHTML = '#sovrn_beacon { display: none} img[src*=\"serving\"] {display: none} img[src*=\"pixel\"] {display: none} img[src*=\"flashtalking\"] {display: none} img[src*=\"doubleclick\"] {display: none} img[src*=\"connatix\"] {display: none} img[src*=\"researchnow\"] {display: none}';\
            document.head.appendChild(style);\
            var settingNode = document.createElement(\"li\");\
            var aTag = document.createElement('a');\
            settingNode.appendChild(aTag);\
            aTag.setAttribute('href',\"/app/settings\");\
            aTag.setAttribute('class',\"btn-primary-sm\");\
            aTag.innerHTML = \"App Settings\";\
            if (document.getElementsByClassName(\"main-navigation\")[0].children[0].getElementsByTagName(\"li\").length == 5) {\
                document.getElementsByClassName(\"main-navigation\")[0].children[0].insertAdjacentElement('afterbegin', settingNode);\
            }\
            \"a\"";
    [self.webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
            NSDate* now = [NSDate date];
            if ([now timeIntervalSinceDate:startDate] < 5.0f) {
                [self webChanges];
            }
        }
    }];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self webChanges];
}

// Handle progress change
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.webView) {
        // NSLog(@"%f", self.webView.estimatedProgress);
        [self.progView setAlpha:1.0f];
        [self.progView setProgress:self.webView.estimatedProgress animated:YES];
        // Almost finish
        if (self.webView.estimatedProgress >= 0.85f) {
            [self.progView setProgress:1.0f];
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progView setProgress:0.0f animated:NO];
            }];
            // Refresher
            if (!refreshControl) {
                refreshControl = [[UIRefreshControl alloc] init];
                NSString *js = @"document.getElementById(\"header\").offsetHeight";
                [self.webView evaluateJavaScript:js completionHandler:^(NSString *result, NSError *error) {
                    NSInteger height = [result integerValue];
                    refreshControl.bounds = CGRectMake(refreshControl.bounds.origin.x,
                                                       height,
                                                       refreshControl.bounds.size.width,
                                                       refreshControl.bounds.size.height);
                    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
                    [self.webView.scrollView addSubview:refreshControl];
                    [refreshControl didMoveToSuperview];
                    [refreshControl setValue:@(80) forKey:@"_snappingHeight"];
                }];
            }
        }
    } else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if ([self isViewLoaded]) {
        [self.webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    }
    [self.webView setNavigationDelegate:nil];
    [self.webView setUIDelegate:nil];
}
@end
