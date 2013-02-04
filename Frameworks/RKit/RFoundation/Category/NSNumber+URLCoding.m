//
//  NSNumber+URLCoding.m
//  VMovier
//
//  Created by Alex Rezit on 20/12/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"
#import "NSNumber+URLCoding.h"

@implementation NSNumber (URLCoding)

- (NSString *)URLEncodedString
{
    return self.stringValue.URLEncodedString;
}

@end
