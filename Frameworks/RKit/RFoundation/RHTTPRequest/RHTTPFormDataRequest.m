//
//  RHTTPFormDataRequest.m
//  RSocialDemo
//
//  Created by Alex Rezit on 03/02/2013.
//  Copyright (c) 2013 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "RHTTPFormDataRequest.h"

@implementation RHTTPFormDataRequest

+ (NSDictionary *)sendSynchronousFormDataRequestForURL:(NSURL *)url
                                               headers:(NSDictionary *)headers
                                           requestBody:(NSDictionary *)requestDictionary
                                       responseHeaders:(NSDictionary **)responseHeaders
{
    RHTTPFormDataRequest *request = [self formDataRequestForURL:url headers:headers requestBody:requestDictionary];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        NSLog(@"RHTTPRequest: URL connection error \n%@", error.description);
    }
    if (responseHeaders) {
        *responseHeaders = response.allHeaderFields;
    }
    NSDictionary *responseDictionary = nil;
    if (responseData) {
        NSError *error = nil;
        responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"RHTTPRequest: JSON parsing error \n%@", error.description);
        }
        if (!responseDictionary) {
            NSString *responseString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
            responseDictionary = responseString.URLDecodedDictionary;
        }
    }
    return responseDictionary;
}

+ (void)sendAsynchronousFormDataRequestForURL:(NSURL *)url
                                      headers:(NSDictionary *)headers
                                  requestBody:(NSDictionary *)requestDictionary
                                   completion:(void (^)(NSDictionary *, NSDictionary *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *responseHeaders = nil;
        NSDictionary *responseDictionary = [self sendSynchronousFormDataRequestForURL:url
                                                                              headers:headers
                                                                          requestBody:requestDictionary
                                                                      responseHeaders:&responseHeaders];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(responseHeaders, responseDictionary);
        });
    });
}

+ (RHTTPFormDataRequest *)formDataRequestForURL:(NSURL *)requestURL headers:(NSDictionary *)headers requestBody:(NSDictionary *)requestDictionary
{
    RHTTPFormDataRequest *formDataRequest = [[[RHTTPFormDataRequest alloc] initWithURL:requestURL] autorelease];
    formDataRequest.HTTPMethod = HTTPMethodPOST;
    formDataRequest.allHTTPHeaderFields = headers;
    
    NSString *boundary = nil;
    __block NSMutableData *bodyData = nil;
    while (TRUE) {
        __block BOOL isBoundaryValid = YES;
        // Generate boundary
        NSUInteger randomStringLength = 16;
        NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];
        NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        for (NSUInteger idx = 0; idx < randomStringLength; idx++) {
            [randomString appendString:[NSString stringWithFormat:@"%C", [letters characterAtIndex:arc4random() % letters.length]]];
        }
        boundary = [NSString stringWithFormat:@"----RHTTPFormDataBoundary%@", randomString];
        
        // Generate data
        bodyData = [NSMutableData data];
        [requestDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]] ||
                [key isKindOfClass:[NSNumber class]]) {
                NSMutableData *partData = [NSMutableData data];
                
                // Boundary
                [partData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                // Key
                NSString *keyString = [key URLEncodedString];
                if ([obj isKindOfClass:[NSString class]] ||
                    [obj isKindOfClass:[NSNumber class]] ||
                    [obj isKindOfClass:[NSArray class]] ||
                    [obj isKindOfClass:[NSSet class]] ||
                    [obj isKindOfClass:[NSOrderedSet class]]) {
                    [partData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
                } else {
                    [partData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", keyString] dataUsingEncoding:NSUTF8StringEncoding]];
                }
                
                // Obj
                NSData *objData = nil;
                if ([obj isKindOfClass:[NSString class]]) {
                    objData = [obj dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    objData = [[obj stringValue] dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSArray class]] ||
                           [obj isKindOfClass:[NSSet class]] ||
                           [obj isKindOfClass:[NSOrderedSet class]]) {
                    NSMutableArray *objComponents = [NSMutableArray arrayWithCapacity:[obj count]];
                    for (id objComponent in obj) {
                        NSString *objComponentString = nil;
                        if ([objComponent isKindOfClass:[NSString class]]) {
                            objComponentString = objComponent;
                        } else if ([objComponent isKindOfClass:[NSNumber class]]) {
                            objComponentString = [objComponent stringValue];
                        }
                        [objComponents addObject:objComponentString];
                    }
                    objData = [[objComponents componentsJoinedByString:@","] dataUsingEncoding:NSUTF8StringEncoding];
                } else if ([obj isKindOfClass:[NSData class]]) {
                    objData = obj;
                    [partData appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                } else if ([obj isKindOfClass:[UIImage class]]) {
                    objData = UIImagePNGRepresentation(obj);
                    [partData appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                }
                [partData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                if (objData && [objData rangeOfData:[boundary dataUsingEncoding:NSUTF8StringEncoding] options:NULL range:NSMakeRange(0, objData.length)].location != NSNotFound) {
                    bodyData = nil;
                    isBoundaryValid = NO;
                    *stop = YES;
                } else {
                    [partData appendData:objData];
                }
                
                // End
                [partData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                
                [bodyData appendData:partData];
            }
        }];
        
        [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        if (isBoundaryValid) {
            break;
        }
    }
    formDataRequest.HTTPBody = bodyData;
    [formDataRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [formDataRequest setValue:@(bodyData.length).stringValue forHTTPHeaderField:@"Content-Length"];
    
    return formDataRequest;
}

@end
