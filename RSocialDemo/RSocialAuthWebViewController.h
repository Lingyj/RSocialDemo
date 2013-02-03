//
//  RSocialAuthWebViewController.h
//  RSocialDemo
//
//  Created by Alex Rezit on 16/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSocialAuthWebViewController;

@protocol RSocialAuthWebViewControllerDelegate <NSObject>

@optional

- (void)authWebViewControllerDidDismiss:(RSocialAuthWebViewController *)viewController;

- (void)authWebViewController:(RSocialAuthWebViewController *)viewController didSucceedWithResponseDictionary:(NSDictionary *)responseDictionary;
- (void)authWebViewControllerDidCancel:(RSocialAuthWebViewController *)viewController;
//- (void)authWebViewController:(RSocialAuthWebViewController *)viewController didFailWithError:(NSError *)error;

@end

@interface RSocialAuthWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id<RSocialAuthWebViewControllerDelegate> delegate;

+ (void)promptWithAuthURL:(NSURL *)authURL
              callbackURL:(NSURL *)callbackURL
                 delegate:(id<RSocialAuthWebViewControllerDelegate>)delegate;
+ (UINavigationController *)navigationControllerWithAuthURL:(NSURL *)authURL
                                                callbackURL:(NSURL *)callbackURL
                                                   delegate:(id<RSocialAuthWebViewControllerDelegate>)delegate;

@end
