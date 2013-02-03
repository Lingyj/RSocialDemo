//
//  RSocialAuthWebViewController.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "MBProgressHUD.h"
#import "RSocialAuthWebViewController.h"

@interface RSocialAuthWebViewController ()

@property (nonatomic, strong) NSURL *authURL;
@property (nonatomic, strong) NSURL *callbackURL;

@property (nonatomic, strong) UIBarButtonItem *cancelBarButton;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButton;
@property (nonatomic, strong) UIBarButtonItem *stopBarButton;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

// Actions
- (void)cancelButtonPressed:(UIButton *)button;
- (void)refreshButtonPressed:(UIButton *)button;
- (void)stopButtonPressed:(UIButton *)button;

// Web view control
- (void)loadAuthPage;
- (void)stopLoading;

// View control
- (void)dismiss;

@end

@implementation RSocialAuthWebViewController

#pragma mark - Actions

- (void)cancelButtonPressed:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(authWebViewControllerDidCancel:)]) {
        [self.delegate authWebViewControllerDidCancel:self];
    }
    [self dismiss];
}

- (void)refreshButtonPressed:(UIButton *)button
{
    [self loadAuthPage];
}

- (void)stopButtonPressed:(UIButton *)button
{
    [self stopLoading];
}

#pragma mark - Web view control

- (void)loadAuthPage
{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authURL];
    [self.webView loadRequest:request];
}

- (void)stopLoading
{
    [self.webView stopLoading];
}

#pragma mark - View control

- (void)dismiss
{
    self.webView.delegate = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(authWebViewControllerDidDismiss:)]) {
            [self.delegate authWebViewControllerDidDismiss:self];
        }
    }];
}

#pragma mark - Life cycle

+ (void)promptWithAuthURL:(NSURL *)authURL callbackURL:(NSURL *)callbackURL delegate:(id<RSocialAuthWebViewControllerDelegate>)delegate
{
    // Find the window on the top.
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *topWindow = application.keyWindow;
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        for (UIWindow *window in application.windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                topWindow = window;
                break;
            }
        }
    }
    
    // Present view controller.
    UINavigationController *navigationController = [RSocialAuthWebViewController navigationControllerWithAuthURL:authURL callbackURL:callbackURL delegate:delegate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [topWindow.rootViewController presentViewController:navigationController animated:YES completion:nil];
    });
}

+ (UINavigationController *)navigationControllerWithAuthURL:(NSURL *)authURL
                                                callbackURL:(NSURL *)callbackURL
                                                   delegate:(id<RSocialAuthWebViewControllerDelegate>)delegate
{
    RSocialAuthWebViewController *authWebViewController = [[[[self class] alloc] init] autorelease];
    authWebViewController.delegate = delegate;
    authWebViewController.authURL = authURL;
    authWebViewController.callbackURL = callbackURL;
    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:authWebViewController] autorelease];
    return navigationController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)] autorelease];
    self.cancelBarButton = cancelBarButton;
    
    UIBarButtonItem *refreshBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)] autorelease];
    self.refreshBarButton = refreshBarButton;
    
    UIBarButtonItem *stopBarButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopButtonPressed:)] autorelease];
    self.stopBarButton = stopBarButton;
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButton;
    self.navigationItem.rightBarButtonItem = self.refreshBarButton;
    
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleHeight);
    webView.delegate = self;
    self.webView = webView;
    [self.view addSubview:webView];
    
    MBProgressHUD *progressHUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    progressHUD.minShowTime = 0.3f;
    self.progressHUD = progressHUD;
    [self.view addSubview:progressHUD];
}

- (void)dealloc
{
    self.webView.delegate = nil;
    
    self.authURL = nil;
    self.callbackURL = nil;
    
    self.cancelBarButton = nil;
    self.refreshBarButton = nil;
    self.stopBarButton = nil;
    self.webView = nil;
    self.progressHUD = nil;
    
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadAuthPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Interface orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? YES : toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Web view delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationItem setRightBarButtonItem:self.stopBarButton animated:YES];
    [self.progressHUD show:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationItem setRightBarButtonItem:self.refreshBarButton animated:YES];
    [self.progressHUD hide:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.navigationItem setRightBarButtonItem:self.refreshBarButton animated:YES];
    [self.progressHUD hide:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldLoad = YES;
    if (webView == self.webView) {
        if ([request.URL.absoluteString rangeOfString:self.callbackURL.absoluteString].location == 0) {
            NSDictionary *responseDictionary = [request.URL.query URLDecodedDictionary];
            shouldLoad = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(authWebViewController:didSucceedWithResponseDictionary:)]) {
                    [self.delegate authWebViewController:self didSucceedWithResponseDictionary:responseDictionary];
                }
                [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1f];
            });
        }
    }
    return shouldLoad;
}

@end
