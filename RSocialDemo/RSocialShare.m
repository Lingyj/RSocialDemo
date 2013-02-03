//
//  RSocialShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 29/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialShare.h"

@interface RSocialShare ()

- (void)share;

@end

@implementation RSocialShare

#pragma mark - External

- (void)showForm
{
#warning Show share form.
}

#pragma mark - Share flow

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

@end
