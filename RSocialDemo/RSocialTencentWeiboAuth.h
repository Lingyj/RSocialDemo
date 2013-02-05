//
//  RSocialTencentWeiboAuth.h
//  RSocialDemo
//
//  Created by Alex Rezit on 18/01/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RSocialOAuth.h"

extern NSString * const kRSocialTencentWeiboAuthPromptLink;
extern NSString * const kRSocialTencentWeiboAuthAccessTokenLink;

@interface RSocialTencentWeiboAuth : RSocialOAuth

@property (nonatomic, strong) NSString *openID;

@end
