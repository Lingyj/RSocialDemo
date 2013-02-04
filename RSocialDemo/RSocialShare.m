//
//  RSocialShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 29/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "MBProgressHUD.h"
#import "RSocialShare.h"

@interface RSocialShare ()

@property (nonatomic, assign) dispatch_semaphore_t isDisplayingShareFormViewSem;

// Share flow
- (void)promptWithShareForm;
- (void)handleFormContent:(NSDictionary *)content;
- (void)share;

@end

@implementation RSocialShare

#pragma mark - External

- (void)showForm
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t isDisplayingShareFormViewSem = dispatch_semaphore_create(0);
        self.isDisplayingShareFormViewSem = isDisplayingShareFormViewSem;
        [self promptWithShareForm];
        dispatch_semaphore_wait(isDisplayingShareFormViewSem, DISPATCH_TIME_FOREVER);
        dispatch_release(isDisplayingShareFormViewSem);
        self.isDisplayingShareFormViewSem = NULL;
    });
    
}

#pragma mark - Share flow

- (void)promptWithShareForm
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    [content setValue:self.content forKey:kRSocialShareContentKeyContent];
    [content setValue:self.image forKey:kRSocialShareContentKeyImage];
    [content setValue:self.imageLink forKey:kRSocialShareContentKeyImageLink];
    [content setValue:self.link forKey:kRSocialShareContentKeyLink];
    [content setValue:self.linkTitle forKey:kRSocialShareContentKeyLinkTitle];
    [content setValue:self.linkDescription forKey:kRSocialShareContentKeyLinkDescription];
    [content setValue:self.linkImageLink forKey:kRSocialShareContentKeyLinkImageLink];
    if (self.maxTextLength) {
        [content setValue:@(self.maxTextLength) forKey:kRSocialShareContentKeyMaxTextLength];
    }
    [RSocialShareFormViewController promptWithContent:content delegate:self];
}

- (void)handleFormContent:(NSDictionary *)content
{
    self.content = content[kRSocialShareContentKeyContent];
    self.image = content[kRSocialShareContentKeyImage];
    self.imageLink = content[kRSocialShareContentKeyImageLink];
    self.link = content[kRSocialShareContentKeyLink];
    self.linkTitle = content[kRSocialShareContentKeyLinkTitle];
    self.linkDescription = content[kRSocialShareContentKeyLinkDescription];
    self.linkImageLink = content[kRSocialShareContentKeyLinkImageLink];
    [self share];
}

- (void)share
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Find the window on the top.
        __block UIApplication *application = [UIApplication sharedApplication];
        __block UIWindow *topWindow = application.keyWindow;
        if (topWindow.windowLevel != UIWindowLevelNormal) {
            for (UIWindow *window in application.windows) {
                if (window.windowLevel == UIWindowLevelNormal) {
                    topWindow = window;
                    break;
                }
            }
        }
        // Prepare progress HUD
        __block MBProgressHUD *progressHUD = [[[MBProgressHUD alloc] initWithWindow:topWindow] autorelease];
        [topWindow.rootViewController.view addSubview:progressHUD];
        progressHUD.labelText = NSLocalizedString(@"RSOCIAL_SHARE_AUTHORIZING", nil);
        [progressHUD show:YES];
        
        // Authorize
        [self.auth authorizeWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    // Update HUD
                    progressHUD.labelText = NSLocalizedString(@"RSOCIAL_SHARE_SENDING", nil);
                    
                    // Send form
                    [self sendFormWithCompletionHandler:^(BOOL success, NSDictionary *status, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (success) {
                                // Update HUD
                                progressHUD.mode = MBProgressHUDModeCustomView;
                                progressHUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RSocialCheckmark"]] autorelease];
                                progressHUD.labelText = NSLocalizedString(@"RSOCIAL_SHARE_SUCCESS", nil);
                                
                                
                                if ([self.delegate respondsToSelector:@selector(socialShare:didFinishWithStatus:)]) {
                                    [self.delegate socialShare:self didFinishWithStatus:status];
                                }
                            } else {
                                // Update HUD
                                progressHUD.labelText = NSLocalizedString(@"RSOCIAL_SHARE_FAIL", nil);
                                
                                // Use delegate
                                if ([self.delegate respondsToSelector:@selector(socialShare:didFailWithError:)]) {
                                    [self.delegate socialShare:self didFailWithError:error];
                                }
                            }
                            
                            // Update HUD
                            [progressHUD hide:YES afterDelay:0.3f];
                        });
                    }];
                } else {
                    // Update HUD
                    progressHUD.labelText = NSLocalizedString(@"RSOCIAL_SHARE_AUTH_FAIL", nil);
                    [progressHUD hide:YES afterDelay:0.3f];
                    
                    // Use delegate
                    if ([self.delegate respondsToSelector:@selector(socialShare:didFailWithError:)]) {
                        NSError *error = nil;
#warning Add error.
                        [self.delegate socialShare:self didFailWithError:error];
                    }
                }
            });
        }];
    });
}

- (void)sendFormWithCompletionHandler:(void (^)(BOOL success, NSDictionary *status, NSError *error))completion
{
    NSAssert(0, @"RSocialShare: Method not implemented.");
}

#pragma mark - Getters and setters

- (NSData *)imageData
{
    return UIImagePNGRepresentation(self.image);
}

#pragma mark - Life cycle

- (id)init
{
    self = [super init];
    if (self) {
        self.maxTextLength = 280;
    }
    return self;
}

#pragma mark - Share form view controller delegate

- (void)shareFormViewControllerDidDismiss:(RSocialShareFormViewController *)viewController
{
    dispatch_semaphore_signal(self.isDisplayingShareFormViewSem);
}

- (void)shareFormViewController:(RSocialShareFormViewController *)viewController didFinishWithContent:(NSDictionary *)content
{
    [self handleFormContent:content];
}

@end
