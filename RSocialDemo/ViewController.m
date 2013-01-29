//
//  ViewController.m
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "MBProgressHUD.h"
#import "RSocialDoubanAuth.h"
#import "RSocialSinaWeiboAuth.h"
#import "RSocialRenrenAuth.h"
#import "RSocialTencentWeiboAuth.h"
#import "RSocialTencentQQAuth.h"
#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UILabel *accessTokenLabel;
@property (nonatomic, strong) IBOutlet UILabel *accessTokenTimeoutLabel;
@property (nonatomic, strong) IBOutlet UILabel *refreshTokenLabel;
@property (nonatomic, strong) IBOutlet UILabel *refreshTokenTimeoutLabel;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) RSocialDoubanAuth *doubanAuth;
@property (nonatomic, strong) RSocialSinaWeiboAuth *sinaWeiboAuth;
@property (nonatomic, strong) RSocialRenrenAuth *renrenAuth;
@property (nonatomic, strong) RSocialTencentWeiboAuth *tencentWeiboAuth;
@property (nonatomic, strong) RSocialTencentQQAuth *tencentQQAuth;

- (IBAction)checkButtonPressed:(UIButton *)button;
- (IBAction)loginButtonPressed:(UIButton *)button;
- (IBAction)logoutButtonPressed:(UIButton *)button;

- (void)updateStatusLabels;

@end

@implementation ViewController

- (void)checkButtonPressed:(UIButton *)button
{
    self.statusLabel.text = NSLocalizedString(@"Checking", nil);
    MBProgressHUD *progressHUD = self.progressHUD;
    progressHUD.labelText = NSLocalizedString(@"Checking...", nil);
    [progressHUD show:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.sinaWeiboAuth checkAuthorizationUpdate];
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
            [self updateStatusLabels];
        });
    });
}

- (void)loginButtonPressed:(UIButton *)button
{
    MBProgressHUD *progressHUD = self.progressHUD;
    progressHUD.labelText = NSLocalizedString(@"Logging in...", nil);
    [progressHUD show:YES];
    [self.sinaWeiboAuth authorizeWithCompletionHandler:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressHUD hide:YES];
            [self updateStatusLabels];
        });
    }];
}

- (void)logoutButtonPressed:(UIButton *)button
{
    [self.sinaWeiboAuth logout];
    [self updateStatusLabels];
}

#pragma mark - View control

- (void)updateStatusLabels
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RSocialOAuth *auth = self.sinaWeiboAuth;
        self.statusLabel.text = auth.isAuthorized ? NSLocalizedString(@"Authed", nil) : NSLocalizedString(@"Not Authed", nil);
        self.accessTokenLabel.text = auth.accessToken;
        self.accessTokenTimeoutLabel.text = auth.accessTokenTimeout.description;
        self.refreshTokenLabel.text = auth.refreshToken;
        self.refreshTokenTimeoutLabel.text = auth.refreshTokenTimeout.description;
    });
}

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MBProgressHUD *progressHUD = [[[MBProgressHUD alloc] initWithView:self.view] autorelease];
    progressHUD.minShowTime = 0.3f;
    self.progressHUD = progressHUD;
    [self.view addSubview:progressHUD];
    
    self.doubanAuth = [RSocialDoubanAuth sharedAuth];
    self.sinaWeiboAuth = [RSocialSinaWeiboAuth sharedAuth];
    self.renrenAuth = [RSocialRenrenAuth sharedAuth];
    self.tencentWeiboAuth = [RSocialTencentWeiboAuth sharedAuth];
    self.tencentQQAuth = [RSocialTencentQQAuth sharedAuth];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateStatusLabels];
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

@end
