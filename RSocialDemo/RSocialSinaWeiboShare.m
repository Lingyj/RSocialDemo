//
//  RSocialSinaWeiboShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 04/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "RHTTPFormDataRequest.h"
#import "RSocialSinaWeiboAuth.h"
#import "RSocialSinaWeiboShare.h"

NSString * const kRSocialSinaWeiboShareLinkNormal = @"https://api.weibo.com/2/statuses/update.json";
NSString * const kRSocialSinaWeiboShareLinkImageUpload = @"https://upload.api.weibo.com/2/statuses/upload.json";
NSString * const kRSocialSinaWeiboShareLinkImageURL = @"https://api.weibo.com/2/statuses/upload_url_text.json";

@interface RSocialSinaWeiboShare ()

- (NSString *)shortLinkForLink:(NSString *)link;

@end

@implementation RSocialSinaWeiboShare

#pragma mark - Share flow

- (void)sendFormWithCompletionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *requestLink = nil;
        
        // Set OAuth parameter
        NSString *accessToken = self.auth.accessToken;
        NSMutableDictionary *requestDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:accessToken, @"access_token", nil];
        
        // Set content
        [requestDictionary setValue:self.auth.clientID forKey:@"source"];
        NSMutableString *content = [self.content.mutableCopy autorelease];
        if (self.link) {
            [content appendFormat:@" %@", [self shortLinkForLink:self.link]];
        }
        
        NSMutableURLRequest *request = nil;
        if (self.image) {
            requestLink = kRSocialSinaWeiboShareLinkImageUpload;
            [requestDictionary setValue:self.image forKey:@"pic"];
            NSURL *requestURL = [NSURL URLWithString:requestLink];
            [requestDictionary setValue:content.URLEncodedString forKey:@"status"];
            request = [RHTTPFormDataRequest formDataRequestForURL:requestURL headers:nil requestBody:requestDictionary];
        } else {
            if (self.imageLink) {
                requestLink = kRSocialSinaWeiboShareLinkImageURL;
                [requestDictionary setValue:self.imageLink forKey:@"url"];
            } else {
                requestLink = kRSocialSinaWeiboShareLinkNormal;
            }
            [requestDictionary setValue:content forKey:@"status"];
            NSURL *requestURL = [NSURL URLWithString:requestLink];
            request = [RHTTPRequest requestForURL:requestURL method:HTTPMethodPOST headers:nil requestBody:requestDictionary];
        }
        
        // Send request
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
                NSInteger errorCode = [responseDictionary[@"error_code"] integerValue];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: responseDictionary[@"error"]}];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, responseDictionary, error);
        });
    });
}

#pragma mark - Utils

- (NSString *)shortLinkForLink:(NSString *)link
{
#warning Add link shorten API.
    return @"";
}

#pragma mark - Getters and setters

- (RSocialOAuth *)auth
{
    return [RSocialSinaWeiboAuth sharedAuth];
}

@end
