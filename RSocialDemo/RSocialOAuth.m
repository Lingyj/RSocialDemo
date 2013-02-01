//
//  RSocialOAuth.m
//  RSocialDemo
//
//  Created by Alex Rezit on 17/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "RHTTPRequest.h"
#import "RSocialOAuth.h"

// Use this offset to avoid inexactness when determining whether the tokens are valid.
// For example, if the expires_in value is 3600 (60 min), the token will appear to be invalid after (60 - 5) = 55 min.
NSTimeInterval const kRSocialOAuthTimeoutOffset = 300; // 5 min

@interface RSocialOAuth ()

@property (nonatomic, readonly) BOOL isAccessTokenValid;
@property (nonatomic, readonly) BOOL isRefreshTokenValid;

@property (nonatomic, assign) dispatch_semaphore_t isAuthorizingViaWebViewSem;

// Auth flow
- (void)promptWithWebView;
- (void)getAccessTokenWithAuthCode;
- (void)getAccessTokenWithRefreshToken;

@end

@implementation RSocialOAuth

#pragma mark - External

// Status

- (BOOL)isAuthorized
{
    return self.isAccessTokenValid;
}

- (BOOL)checkAuthorizationUpdate
{
    BOOL isAuthorized = NO;
    if (self.isAccessTokenValid) {
        isAuthorized = YES;
    } else {
        if (self.isRefreshTokenValid) {
            [self getAccessTokenWithRefreshToken];
        }
        if (self.isAccessTokenValid) {
            isAuthorized = YES;
        }
    }
    return isAuthorized;
}

// Actions

- (void)authorizeWithCompletionHandler:(void (^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = NO;
        if (self.isAccessTokenValid) {
            success = YES;
        } else {
            self.accessToken = nil;
            self.accessTokenTimeout = nil;
            if (self.isRefreshTokenValid) {
                [self getAccessTokenWithRefreshToken];
            } else {
                self.refreshToken = nil;
                self.refreshTokenTimeout = nil;
            }
            if (!self.accessToken) {
                dispatch_semaphore_t isAuthorizingViaWebViewSem = dispatch_semaphore_create(0);
                self.isAuthorizingViaWebViewSem = isAuthorizingViaWebViewSem;
                [self promptWithWebView];
                dispatch_semaphore_wait(isAuthorizingViaWebViewSem, DISPATCH_TIME_FOREVER);
                dispatch_release(isAuthorizingViaWebViewSem);
                self.isAuthorizingViaWebViewSem = NULL;
                [self getAccessTokenWithAuthCode];
            }
            if (self.isAccessTokenValid) {
                success = YES;
            }
        }
        completion(success);
    });
}

- (void)deactivateAccessToken
{
    self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:-1];
}

- (void)logout
{
    self.code = nil;
    self.accessToken = nil;
    self.accessTokenTimeout = nil;
    self.refreshToken = nil;
    self.refreshTokenTimeout = nil;
}

#pragma mark - Getters and setters

- (BOOL)isAccessTokenValid
{
    BOOL isAccessTokenValid = NO;
    if (self.accessToken && self.accessTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.accessTokenTimeout dateByAddingTimeInterval:kRSocialOAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isAccessTokenValid = YES;
        }
    }
    return isAccessTokenValid;
}

- (BOOL)isRefreshTokenValid
{
    BOOL isRefreshTokenValid = NO;
    if (self.refreshToken && self.refreshTokenTimeout) {
        NSDate *currentDate = [NSDate date];
        NSComparisonResult comparisonResult = [currentDate compare:[self.refreshTokenTimeout dateByAddingTimeInterval:kRSocialOAuthTimeoutOffset]];
        if (comparisonResult == NSOrderedAscending) {
            isRefreshTokenValid = YES;
        }
    }
    return isRefreshTokenValid;
}

#pragma mark - Auth flow

- (void)promptWithWebView
{
    if (!self.scope) {
        self.scope = @"";
    }
    NSDictionary *authRequestDictionary = self.webViewAuthRequestDictionary;
    NSURL *urlWithData = [NSURL URLWithString:[self.authorizeLink stringByAppendingFormat:@"?%@", [NSString stringWithURLEncodedDictionary:authRequestDictionary]]];
    [RSocialAuthWebViewController promptWithAuthURL:urlWithData callbackURL:[NSURL URLWithString:self.redirectURI] delegate:self];
}

- (void)getAccessTokenWithAuthCode
{
    if (self.code) {
        NSURL *requestURL = [NSURL URLWithString:self.accessTokenLink];
        NSDictionary *requestDictionary = self.codeAuthRequestDictionary;
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [RHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                               method:HTTPMethodPOST
                                                                              headers:nil
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        [self handleCodeAuthResponse:responseDictionary];
    }
}

- (void)getAccessTokenWithRefreshToken
{
    if (self.refreshToken) {
        NSURL *requestURL = [NSURL URLWithString:self.accessTokenLink];
        NSDictionary *requestDictionary = self.refreshTokenAuthRequestDictionary;
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [RHTTPRequest sendSynchronousRequestForURL:requestURL
                                                                               method:HTTPMethodPOST
                                                                              headers:nil
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        [self handleRefreshTokenAuthResponse:responseDictionary];
    }
}

- (NSDictionary *)webViewAuthRequestDictionary
{
    NSDictionary *authRequestDictionary = @{
    @"client_id" : self.clientID,
    @"client_secret" : self.clientSecret,
    @"redirect_uri" : self.redirectURI,
    @"response_type" : @"code",
    @"scope" : self.scope
    };
    return authRequestDictionary;
}

- (NSDictionary *)codeAuthRequestDictionary
{
    NSDictionary *requestDictionary = @{
    @"client_id" : self.clientID,
    @"client_secret" : self.clientSecret,
    @"redirect_uri" : self.redirectURI,
    @"grant_type" : @"authorization_code",
    @"code" : self.code
    };
    return requestDictionary;
}

- (NSDictionary *)refreshTokenAuthRequestDictionary
{
    NSDictionary *requestDictionary = @{
    @"client_id" : self.clientID,
    @"client_secret" : self.clientSecret,
    @"redirect_uri" : self.redirectURI,
    @"grant_type" : @"refresh_token",
    @"refresh_token" : self.refreshToken
    };
    return requestDictionary;
}

- (void)handleWebViewAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.code = responseDictionary[@"code"];
    }
}

- (void)handleCodeAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.accessToken = responseDictionary[@"access_token"];
        self.refreshToken = responseDictionary[@"refresh_token"];
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        if (self.refreshToken) {
            self.refreshTokenTimeout = [NSDate distantFuture];
        }
    }
}

- (void)handleRefreshTokenAuthResponse:(NSDictionary *)responseDictionary
{
    if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
        self.accessToken = responseDictionary[@"access_token"];
        self.refreshToken = responseDictionary[@"refresh_token"];
        NSInteger expiresIn = [responseDictionary[@"expires_in"] integerValue];
        self.accessTokenTimeout = [NSDate dateWithTimeIntervalSinceNow:expiresIn];
        if (self.refreshToken) {
            self.refreshTokenTimeout = [NSDate distantFuture];
        }
    }
}

#pragma mark - Life cycle

+ (id)sharedAuth
{
    static RSocialOAuth *sharedAuth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuth = [[self alloc] init];
    });
    return sharedAuth;
}

- (void)configure
{
    NSAssert(0, @"RSocialOAuth: Method not implemented.");
}

- (id)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark - Auth web view controller delegate

- (void)authWebViewControllerDidDismiss:(RSocialAuthWebViewController *)viewController
{
    dispatch_semaphore_signal(self.isAuthorizingViaWebViewSem);
}

- (void)authWebViewController:(RSocialAuthWebViewController *)viewController didSuccessWithResponseDictionary:(NSDictionary *)responseDictionary
{
    [self handleWebViewAuthResponse:responseDictionary];
}

@end
