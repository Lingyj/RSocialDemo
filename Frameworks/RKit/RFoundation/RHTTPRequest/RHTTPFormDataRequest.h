//
//  RHTTPFormDataRequest.h
//  RSocialDemo
//
//  Created by Alex Rezit on 03/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "RHTTPRequest.h"

@interface RHTTPFormDataRequest : RHTTPRequest

+ (RHTTPFormDataRequest *)formDataRequestForURL:(NSURL *)requestURL
                                        headers:(NSDictionary *)headers
                                    requestBody:(NSDictionary *)requestDictionary;

@end
