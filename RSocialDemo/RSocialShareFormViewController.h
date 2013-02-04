//
//  RSocialShareFormViewController.h
//  RSocialDemo
//
//  Created by Alex Rezit on 03/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kRSocialShareContentKeyContent;

extern NSString * const kRSocialShareContentKeyImage;
extern NSString * const kRSocialShareContentKeyImageLink;

extern NSString * const kRSocialShareContentKeyLink;
extern NSString * const kRSocialShareContentKeyLinkTitle;
extern NSString * const kRSocialShareContentKeyLinkDescription;
extern NSString * const kRSocialShareContentKeyLinkImageLink;

extern NSString * const kRSocialShareContentKeyMaxTextLength;

@class RSocialShareFormViewController;

@protocol RSocialShareFormViewControllerDelegate <NSObject>

@optional

- (void)shareFormViewControllerDidDismiss:(RSocialShareFormViewController *)viewController;
- (void)shareFormViewController:(RSocialShareFormViewController *)viewController didFinishWithContent:(NSDictionary *)content;
- (void)shareFormViewControllerDidCancel:(RSocialShareFormViewController *)viewController;

@end

@interface RSocialShareFormViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) id<RSocialShareFormViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger maxTextLength;

+ (void)promptWithContent:(NSDictionary *)content
                 delegate:(id<RSocialShareFormViewControllerDelegate>)delegate;
+ (UINavigationController *)navigationControllerWithContent:(NSDictionary *)content
                                                   delegate:(id<RSocialShareFormViewControllerDelegate>)delegate;

@end
