//
//  RHTTPRequest.h
//  VMovier
//
//  Created by Alex Rezit on 14/12/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RHTTPRequest : NSMutableURLRequest

extern NSString * const HTTPMethodGET;
extern NSString * const HTTPMethodPOST;
extern NSString * const HTTPMethodPUT;
extern NSString * const HTTPMethodHEAD;
extern NSString * const HTTPMethodDELETE;

+ (NSDictionary *)sendSynchronousRequestForURL:(NSURL *)url
                                        method:(NSString *)method
                                       headers:(NSDictionary *)headers
                                   requestBody:(NSDictionary *)requestDictionary
                               responseHeaders:(NSDictionary **)responseHeaders;
+ (void)sendAsynchronousRequestForURL:(NSURL *)url
                               method:(NSString *)method
                              headers:(NSDictionary *)headers
                          requestBody:(NSDictionary *)requestDictionary
                           completion:(void (^)(NSDictionary *responseHeaders, NSDictionary *responseDictionary))completion;

+ (RHTTPRequest *)requestForURL:(NSURL *)requestURL
                         method:(NSString *)method
                        headers:(NSDictionary *)headers
                    requestBody:(NSDictionary *)requestDictionary;

@end
