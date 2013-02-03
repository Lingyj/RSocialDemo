//
//  RSocialShare.h
//  RSocialDemo
//
//  Created by Alex Rezit on 29/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSocialOAuth.h"

typedef NS_ENUM(NSInteger, RSocialShareType) {
    RSocialShareTypeDefault,
    RSocialShareTypeText,
    RSocialShareTypeImage,
    RSocialShareTypeLink,
    RSocialShareTypeMultiType = RSocialShareTypeDefault
};

typedef NS_ENUM(NSInteger, RSocialShareLinkType) {
    RSocialShareLinkTypeDefault,
    RSocialShareLinkTypeImage,
    RSocialShareLinkTypeAudio,
    RSocialShareLinkTypeVideo,
};

@class RSocialShare;

@protocol RSocialShareDelegate <NSObject>

@optional
- (void)socialShareDidCancel:(RSocialShare *)socialShare;
- (void)socialShare:(RSocialShare *)socialShare didFinishWithStatus:(NSDictionary *)status;
- (void)socialShare:(RSocialShare *)socialShare didFailWithError:(NSError *)error;

@end

@interface RSocialShare : NSObject

@property (nonatomic, assign) id<RSocialShareDelegate> delegate;

@property (nonatomic, readonly) RSocialOAuth *auth;

// Config
@property (nonatomic, assign) RSocialShareType type;

// Text
@property (nonatomic, strong) NSString *content;

// Image
@property (nonatomic, strong) UIImage *image; // Upload
@property (nonatomic, readonly) NSData *imageData; // Returns data of self.image
@property (nonatomic, strong) NSString *imageLink; // Use web image

// Link (including audio and video)
@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) RSocialShareLinkType linkType;
@property (nonatomic, strong) NSString *linkTitle;
@property (nonatomic, strong) NSString *linkDescription;
@property (nonatomic, strong) NSString *linkImageLink;

#pragma mark - Getters and setters
// Implement this method to return a shared instance of RSocialOAuth.
- (RSocialOAuth *)auth;

#pragma mark - Actions
- (void)showForm;

#pragma mark - Share flow
// Implement this method to send share request.
- (void)sendFormWithCompletionHandler:(void (^)(BOOL success, NSDictionary *status, NSError *error))completion;

@end
