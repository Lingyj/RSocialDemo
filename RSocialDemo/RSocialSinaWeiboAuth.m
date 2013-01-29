//
//  RSocialSinaWeiboAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 17/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialSinaWeiboAuth.h"

#define kRSocialSinaWeiboAuthKeyAccessToken @"SinaWeiboAccessToken"
#define kRSocialSinaWeiboAuthKeyRefreshToken @"SinaWeiboRefreshToken"
#define kRSocialSinaWeiboAuthKeyAccessTokenTimeout @"SinaWeiboAccessTokenTimeout"
#define kRSocialSinaWeiboAuthKeyRefreshTokenTimeout @"SinaWeiboRefreshTokenTimeout"

NSString * const kRSocialSinaWeiboAuthPromptLink = @"https://api.weibo.com/oauth2/authorize";
NSString * const kRSocialSinaWeiboAuthAccessTokenLink = @"https://api.weibo.com/oauth2/access_token";

@interface RSocialSinaWeiboAuth ()

@end

@implementation RSocialSinaWeiboAuth

#pragma mark - Auth flow

- (NSDictionary *)webViewAuthRequestDictionary
{
    NSMutableDictionary *webViewAuthRequestDictionary = [super.webViewAuthRequestDictionary.mutableCopy autorelease];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [webViewAuthRequestDictionary setValue:@"mobile" forKey:@"display"];
    } else {
        [webViewAuthRequestDictionary setValue:@"default" forKey:@"display"];
    }
    return webViewAuthRequestDictionary;
}

#pragma mark - Getters and setters

#warning ATTENTION!!!
#warning STORE TOKENS IN PLAIN TEXT IS NOT SAFE!!!
#warning PLEASE MODIFY THIS PART WHEN YOU USE MY CODE!!!

- (NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialSinaWeiboAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialSinaWeiboAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialSinaWeiboAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialSinaWeiboAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRSocialSinaWeiboAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRSocialSinaWeiboAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRSocialSinaWeiboAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRSocialSinaWeiboAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"732252004";
    self.clientSecret = @"ac51e4eade5c8a98f2274b92dbe3a179";
    self.redirectURI = @"http://rsocial.seymourdev.com/";
    
    self.authorizeLink = kRSocialSinaWeiboAuthPromptLink;
    self.accessTokenLink = kRSocialSinaWeiboAuthAccessTokenLink;
}

@end
