//
//  RSocialTencentWeiboAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 18/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialTencentWeiboAuth.h"

#define kRSocialTencentWeiboAuthKeyAccessToken @"TencentWeiboAccessToken"
#define kRSocialTencentWeiboAuthKeyRefreshToken @"TencentWeiboRefreshToken"
#define kRSocialTencentWeiboAuthKeyAccessTokenTimeout @"TencentWeiboAccessTokenTimeout"
#define kRSocialTencentWeiboAuthKeyRefreshTokenTimeout @"TencentWeiboRefreshTokenTimeout"

#define kRSocialTencentWeiboStateKeyWebView @"TencentWeiboStateWebView"
#define kRSocialTencentWeiboStateKeyCode @"TencentWeiboStateCode"
#define kRSocialTencentWeiboStateKeyRefreshToken @"TencentWeiboStateRefreshToken"

NSString * const kRSocialTencentWeiboAuthPromptLink = @"https://open.t.qq.com/cgi-bin/oauth2/authorize";
NSString * const kRSocialTencentWeiboAuthAccessTokenLink = @"https://open.t.qq.com/cgi-bin/oauth2/access_token";

@interface RSocialTencentWeiboAuth ()

@property (nonatomic, strong) NSMutableDictionary *authStates; // Used to prevent CSRF attack.

@end

@implementation RSocialTencentWeiboAuth

#pragma mark - Auth flow

- (NSDictionary *)webViewAuthRequestDictionary
{
    NSMutableDictionary *webViewAuthRequestDictionary = [super.webViewAuthRequestDictionary.mutableCopy autorelease];
    NSString *state = @(arc4random()).stringValue;
    [self.authStates setValue:state forKey:kRSocialTencentWeiboStateKeyWebView];
    [webViewAuthRequestDictionary setValue:state forKey:@"state"];
    return webViewAuthRequestDictionary;
}

- (NSDictionary *)codeAuthRequestDictionary
{
    NSMutableDictionary *codeAuthRequestDictionary = [super.codeAuthRequestDictionary.mutableCopy autorelease];
    NSString *state = @(arc4random()).stringValue;
    [self.authStates setValue:state forKey:kRSocialTencentWeiboStateKeyCode];
    [codeAuthRequestDictionary setValue:state forKey:@"state"];
    return codeAuthRequestDictionary;
}

- (NSDictionary *)refreshTokenAuthRequestDictionary
{
    NSMutableDictionary *refreshTokenAuthRequestDictionary = [super.refreshTokenAuthRequestDictionary.mutableCopy autorelease];
    NSString *state = @(arc4random()).stringValue;
    [self.authStates setValue:state forKey:kRSocialTencentWeiboStateKeyRefreshToken];
    [refreshTokenAuthRequestDictionary setValue:state forKey:@"state"];
    return refreshTokenAuthRequestDictionary;
}

- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        if ([responseDictionary[@"state"] isEqualToString:self.authStates[kRSocialTencentWeiboStateKeyWebView]]) {
            [super handleWebViewAuthResponse:responseDictionary];
        }
    }
}

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        if ([responseDictionary[@"state"] isEqualToString:self.authStates[kRSocialTencentWeiboStateKeyCode]]) {
            [super handleCodeAuthResponse:responseDictionary];
        }
    }
}

- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        if ([responseDictionary[@"state"] isEqualToString:self.authStates[kRSocialTencentWeiboStateKeyRefreshToken]]) {
            [super handleRefreshTokenAuthResponse:responseDictionary];
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
    return [userDefaults valueForKey:kRSocialTencentWeiboAuthKeyAccessToken];
}

- (NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentWeiboAuthKeyRefreshToken];
}

- (NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentWeiboAuthKeyAccessTokenTimeout];
}

- (NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:kRSocialTencentWeiboAuthKeyRefreshTokenTimeout];
}

- (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessToken forKey:kRSocialTencentWeiboAuthKeyAccessToken];
    [userDefaults synchronize];
}

- (void)setRefreshToken:(NSString *)refreshToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshToken forKey:kRSocialTencentWeiboAuthKeyRefreshToken];
    [userDefaults synchronize];
}

- (void)setAccessTokenTimeout:(NSDate *)accessTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:accessTokenTimeout forKey:kRSocialTencentWeiboAuthKeyAccessTokenTimeout];
    [userDefaults synchronize];
}

- (void)setRefreshTokenTimeout:(NSDate *)refreshTokenTimeout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:refreshTokenTimeout forKey:kRSocialTencentWeiboAuthKeyRefreshTokenTimeout];
    [userDefaults synchronize];
}

#pragma mark - Life cycle

- (void)configure
{
    self.clientID = @"801300654";
    self.clientSecret = @"a4454f627f3df164aac86db40be2cd6d";
    self.redirectURI = @"http://rsocial.seymourdev.com/";
    
    self.authorizeLink = kRSocialTencentWeiboAuthPromptLink;
    self.accessTokenLink = kRSocialTencentWeiboAuthAccessTokenLink;
    
    self.authStates = [NSMutableDictionary dictionaryWithCapacity:3];
}

@end
