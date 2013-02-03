//
//  RSocialDoubanShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 03/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RHTTPFormDataRequest.h"
#import "RSocialDoubanAuth.h"
#import "RSocialDoubanShare.h"

NSString * const kRSocialDoubanShareLink = @"https://api.douban.com/shuo/v2/statuses/";

@implementation RSocialDoubanShare

#pragma mark - Share flow

- (void)sendFormWithCompletionHandler:(void (^)(BOOL success, NSDictionary *status, NSError *error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Set OAuth header.
        NSString *accessToken = self.auth.accessToken;
        NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Bearer %@", accessToken], @"Authorization", nil];
        
        // Set content.
        NSMutableDictionary *requestDictionary = [NSMutableDictionary dictionary];
        [requestDictionary setValue:self.auth.clientID forKey:@"source"];
        [requestDictionary setValue:self.content forKey:@"text"];
        
        RSocialShareType type = self.type;
        if (type == RSocialShareTypeImage && self.image) {
            // Parameters about link will be ignored.
            [requestHeaders setValue:@"multipart/form-data" forKey:@"Content-Type"];
            [requestDictionary setValue:self.image forKey:@"image"];
        } else if (self.link) {
            [requestDictionary setValue:self.link forKey:@"rec_url"];
            [requestDictionary setValue:self.linkTitle forKey:@"rec_title"];
            [requestDictionary setValue:self.linkDescription forKey:@"rec_desc"];
            RSocialShareLinkType linkType = self.linkType;
            if (linkType == RSocialShareLinkTypeImage) {
                // If an image link is designated, videos will be displayed as normal links.
                [requestDictionary setValue:self.linkImageLink forKey:@"rec_image"];
            }
        }
        
        // Send request.
        NSURL *requestURL = [NSURL URLWithString:kRSocialDoubanShareLink];
        RHTTPFormDataRequest *request = [RHTTPFormDataRequest formDataRequestForURL:requestURL headers:requestHeaders requestBody:requestDictionary];
        NSHTTPURLResponse *response = nil;
        NSError *error = nil;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSDictionary *responseDictionary = nil;
        BOOL success = NO;
        if (responseData) {
            responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
            NSInteger statusCode = response.statusCode;
            success = statusCode == 200;
            if (!success) {
                NSInteger errorCode = [responseDictionary[@"code"] integerValue];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: responseDictionary[@"msg"]}];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, responseDictionary, error);
        });
    });
}

#pragma mark - Getters and setters

- (RSocialOAuth *)auth
{
    return [RSocialDoubanAuth sharedAuth];
}

@end
