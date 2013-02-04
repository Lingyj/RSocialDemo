//
//  RSocialShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 29/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialShare.h"

@interface RSocialShare ()

@property (nonatomic, assign) dispatch_semaphore_t isDisplayingShareFormViewSem;

- (void)promptWithShareForm;
- (void)handleFormContent:(NSDictionary *)content;
- (void)share;

@end

@implementation RSocialShare

#pragma mark - External

- (void)showForm
{
#warning Show share form.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_t isDisplayingShareFormViewSem = dispatch_semaphore_create(0);
        self.isDisplayingShareFormViewSem = isDisplayingShareFormViewSem;
        [self promptWithShareForm];
        dispatch_semaphore_wait(isDisplayingShareFormViewSem, DISPATCH_TIME_FOREVER);
        dispatch_release(isDisplayingShareFormViewSem);
        self.isDisplayingShareFormViewSem = NULL;
        [self share];
    });
    
}

#pragma mark - Share flow

- (void)promptWithShareForm
{
#warning Generate content.
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    [content setValue:self.content forKey:kRSocialShareContentKeyContent];
    [content setValue:self.image forKey:kRSocialShareContentKeyImage];
    [content setValue:self.imageLink forKey:kRSocialShareContentKeyImageLink];
    [content setValue:self.link forKey:kRSocialShareContentKeyLink];
    [content setValue:self.linkTitle forKey:kRSocialShareContentKeyLinkTitle];
    [content setValue:self.linkDescription forKey:kRSocialShareContentKeyLinkDescription];
    [content setValue:self.linkImageLink forKey:kRSocialShareContentKeyLinkImageLink];
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
}

- (void)share
{
    [self.auth authorizeWithCompletionHandler:^(BOOL success) {
        if (success) {
            [self sendFormWithCompletionHandler:^(BOOL success, NSDictionary *status, NSError *error) {
                if (success) {
                    if ([self.delegate respondsToSelector:@selector(socialShare:didFinishWithStatus:)]) {
                        [self.delegate socialShare:self didFinishWithStatus:status];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(socialShare:didFailWithError:)]) {
                        [self.delegate socialShare:self didFailWithError:error];
                    }
                }
            }];
        } else {
            if ([self.delegate respondsToSelector:@selector(socialShare:didFailWithError:)]) {
                NSError *error = nil;
#warning Add error.
                [self.delegate socialShare:self didFailWithError:error];
            }
        }
    }];
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
