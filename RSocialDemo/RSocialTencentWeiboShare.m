//
//  RSocialTencentWeiboShare.m
//  RSocialDemo
//
//  Created by Alex Rezit on 05/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RHTTPFormDataRequest.h"
#import "RSocialTencentWeiboAuth.h"
#import "RSocialTencentWeiboShare.h"

NSString * const kRSocialTencentWeiboShareLinkMultiType = @"https://open.t.qq.com/api/t/add_multi";
NSString * const kRSocialTencentWeiboShareLinkMultiImageUpload = @"https://open.t.qq.com/api/t/upload_pic";

@interface RSocialTencentWeiboShare ()

- (NSString *)clientIP;
- (NSString *)uploadImage:(UIImage *)image;
- (NSString *)shortLinkForLink:(NSString *)link;

@end

@implementation RSocialTencentWeiboShare

#pragma mark - Share flow

- (void)sendFormWithCompletionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *requestLink = kRSocialTencentWeiboShareLinkMultiType;
        NSMutableDictionary *requestDictionary = [NSMutableDictionary dictionary];
        
        // Set OAuth parameter
        NSString *clientID = self.auth.clientID;
        NSString *accessToken = self.auth.accessToken;
        [requestDictionary setValue:clientID forKey:@"oauth_consumer_key"];
        [requestDictionary setValue:accessToken forKey:@"access_token"];
        
        // Set return data format
        [requestDictionary setValue:@"json" forKey:@"format"];
        
        // Set client IP
        NSString *clientIP = self.clientIP;
        [requestDictionary setValue:clientIP forKey:@"clientip"];
#warning Client IP.
        
        // Set content
        NSMutableString *content = [self.content.mutableCopy autorelease];
        
        NSMutableArray *imageLinks = [NSMutableArray array];
        if (self.image) {
            NSString *imageLink = [self uploadImage:self.image];
            [imageLinks addObject:imageLink];
        }
        NSString *link = [self shortLinkForLink:self.link];
        if (link) {
            switch (self.linkType) {
                case RSocialShareLinkTypeImage:
                    [imageLinks addObject:link];
                    break;
                case RSocialShareLinkTypeAudio:
                    [requestDictionary setValue:link forKey:@"music_url"];
                    break;
                case RSocialShareLinkTypeVideo:
                    [requestDictionary setValue:link forKey:@"video_url"];
                    break;
                default:
                    [content appendFormat:@" %@", link];
                    break;
            }
        }
        [requestDictionary setValue:content forKey:@"content"];
        [requestDictionary setValue:imageLinks forKey:@"pic_url"];
        
        // Send request
        NSURL *requestURL = [NSURL URLWithString:requestLink];
        NSDictionary *responseDictionary = [RHTTPRequest sendSynchronousRequestForURL:requestURL method:HTTPMethodPOST headers:nil requestBody:requestDictionary responseHeaders:nil];
        BOOL success = NO;
        NSError *error = nil;
        if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
            if ([responseDictionary[@"ret"] integerValue] == 0) {
                success = YES;
            } else {
                NSInteger errorCode = [responseDictionary[@"errcode"] integerValue];
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: responseDictionary[@"msg"]}];
            }
        }
        completion(success, responseDictionary, error);
    });
}

#pragma mark - Utils

- (NSString *)clientIP
{
    return @"8.8.8.8";
}

- (NSString *)uploadImage:(UIImage *)image
{
    return nil;
}

- (NSString *)shortLinkForLink:(NSString *)link
{
    return nil;
}

#pragma mark - Getters and setters

- (RSocialOAuth *)auth
{
    return [RSocialTencentWeiboAuth sharedAuth];
}

- (void)setLink:(NSString *)link
{
    if (link && self.linkType == RSocialShareLinkTypeDefault) {
        self.maxTextLength = 250;
    }
    [super setLink:link];
}

@end
