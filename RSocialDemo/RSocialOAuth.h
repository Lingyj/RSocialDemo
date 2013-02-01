//
//  RSocialOAuth.h
//  RSocialDemo
//
//  Created by Alex Rezit on 17/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

/*
 * OAuth authorization flow
 *
 * if (access token is valid) {
 *     complete
 * } else if (refresh token is valid) {
 *     refresh token -> access token -> complete
 * } else {
 *     prompt web view -> auth code -> access token (& refresh token)
 * }
 *
 */

#import <Foundation/Foundation.h>
#import "RSocialAuthWebViewController.h"

@interface RSocialOAuth : NSObject <RSocialAuthWebViewControllerDelegate>

// Config
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, strong) NSString *scope;

@property (nonatomic, strong) NSString *authorizeLink;
@property (nonatomic, strong) NSString *accessTokenLink;

// Property
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSDate *accessTokenTimeout;
@property (nonatomic, strong) NSDate *refreshTokenTimeout;

#pragma mark - Life cycle

+ (id)sharedAuth;

// Override this method in subclass.
- (void)configure;

#pragma mark - Actions

// Return YES if access token is currently valid.
- (BOOL)isAuthorized;

// If access token is currently valid, return YES. Or try use refresh token to fetch access token, then return YES if the process succeeded.
- (BOOL)checkAuthorizationUpdate;

// Try authorize using standard auth flow.
- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion;

// Call this method to deactivate access token manually if it is somehow invalid.
- (void)deactivateAccessToken;

// Clears all the information stored.
- (void)logout;

#pragma mark - Auth flow

// These methods can be used to make custom changes to adapt to different platforms.
- (NSDictionary *)webViewAuthRequestDictionary;
- (NSDictionary *)codeAuthRequestDictionary;
- (NSDictionary *)refreshTokenAuthRequestDictionary;
- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary;
- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary;
- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary;

@end
