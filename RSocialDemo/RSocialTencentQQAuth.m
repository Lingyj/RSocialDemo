//
//  RSocialTencentQQAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 26/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialTencentQQAuth.h"

#define kRSocialTencentQQAuthKeyAccessToken @"TencentQQAccessToken"
#define kRSocialTencentQQAuthKeyRefreshToken @"TencentQQRefreshToken"
#define kRSocialTencentQQAuthKeyAccessTokenTimeout @"TencentQQAccessTokenTimeout"
#define kRSocialTencentQQAuthKeyRefreshTokenTimeout @"TencentQQRefreshTokenTimeout"

#define kRSocialTencentQQStateKeyWebView @"TencentQQStateWebView"
#define kRSocialTencentQQStateKeyCode @"TencentQQStateCode"
#define kRSocialTencentQQStateKeyRefreshToken @"TencentQQStateRefreshToken"

NSString * const kRSocialTencentQQAuthPromptLink = @"https://graph.qq.com/oauth2.0/authorize";
NSString * const kRSocialTencentQQAuthAccessTokenLink = @"https://graph.qq.com/oauth2.0/token";

@interface RSocialTencentQQAuth ()

@property (nonatomic, strong) NSMutableDictionary *authStates; // Used to prevent CSRF attack.

@end

@implementation RSocialTencentQQAuth

#pragma mark - Auth flow

- (NSDictionary *)webViewAuthRequestDictionary
{
    NSMutableDictionary *webViewAuthRequestDictionary = [super.webViewAuthRequestDictionary.mutableCopy autorelease];
    NSString *state = @(arc4random()).stringValue;
    [self.authStates setValue:state forKey:kRSocialTencentQQStateKeyWebView];
    [webViewAuthRequestDictionary setValue:state forKey:@"state"];
    return webViewAuthRequestDictionary;
}

- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        if ([responseDictionary[@"state"] isEqualToString:self.authStates[kRSocialTencentQQStateKeyWebView]]) {
            [super handleWebViewAuthResponse:responseDictionary];
        }
    }
}

#pragma mark - Getters and setters

#warning ATTENTION!!!
#warning STORE TOKENS IN PLAIN TEXT IS NOT SAFE!!!
#warning PLEASE MODIFY THIS PART WHEN YOU USE MY CODE!!!

- (NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentQQAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentQQAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentQQAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentQQAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRSocialTencentQQAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRSocialTencentQQAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRSocialTencentQQAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRSocialTencentQQAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"100369927";
    self.clientSecret = @"afee6bdd14f07cf9820e7cd573af89e9";
    self.redirectURI = @"http://rsocial.seymourdev.com/";
    
    self.authorizeLink = kRSocialTencentQQAuthPromptLink;
    self.accessTokenLink = kRSocialTencentQQAuthAccessTokenLink;
    
    self.authStates = [NSMutableDictionary dictionaryWithCapacity:3];
}

@end
