//
//  NSString+URLCoding.m
//  VMovier
//
//  Created by Alex Rezit on 22/11/2012.
//  Copyright (c) 2012 Seymour Dev. All rights reserved.
//

#import "NSString+URLCoding.h"

@implementation NSString (URLCoding)

- (NSString *)URLEncodedString
{
    CFStringRef resultString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)self,
                                                                          NULL,
                                                                          CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                          kCFStringEncodingUTF8);
    return [(NSString *)resultString autorelease];
}

- (NSString *)URLDecodedString
{
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)stringWithURLEncodedDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:dictionary.count];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *objString = nil;
        if ([obj isKindOfClass:[NSString class]]) {
            objString = obj;
        } else if ([obj isKindOfClass:[NSNumber class]]) {
            objString = [obj stringValue];
        } else if ([obj isKindOfClass:[NSArray class]] ||
                   [obj isKindOfClass:[NSSet class]] ||
                   [obj isKindOfClass:[NSOrderedSet class]]) {
            NSMutableArray *objComponents = [NSMutableArray arrayWithCapacity:[obj count]];
            for (id objComponent in obj) {
                NSString *objComponentString = nil;
                if ([objComponent isKindOfClass:[NSString class]]) {
                    objComponentString = [objComponent URLEncodedString];
                } else if ([objComponent isKindOfClass:[NSNumber class]]) {
                    objComponentString = [objComponent stringValue];
                }
                [objComponents addObject:objComponentString];
            }
            objString = [objComponents componentsJoinedByString:@","];
        }
        NSString *component = [NSString stringWithFormat:@"%@=%@",
                               [key URLEncodedString],
                               objString];
        [components addObject:component];
    }];
    NSString *resultString = [components componentsJoinedByString:@"&"];
    [components release];
    return resultString;
}

- (NSDictionary *)URLDecodedDictionary
{
    NSArray *components = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *decodedDictionary = [[NSMutableDictionary alloc] initWithCapacity:components.count];
    [components enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *component = (NSString *)obj;
        NSUInteger dividerLocation = [component rangeOfString:@"="].location;
        if (dividerLocation != NSNotFound &&
            dividerLocation > 0 &&
            dividerLocation < component.length - 1) {
            NSString *key = [component substringToIndex:dividerLocation].URLDecodedString;
            NSString *value = [component substringFromIndex:dividerLocation + 1].URLDecodedString;
            if (![decodedDictionary.allKeys containsObject:key]) {
                [decodedDictionary setValue:value forKey:key];
            } else {
                NSString *oldValue = [decodedDictionary valueForKey:key];
                [decodedDictionary setValue:@[value, oldValue] forKey:key];
            }
        } else {
            NSLog(@"NSString (URLCoding): Wrong param: \"%@\"", component);
        }
    }];
    return decodedDictionary;
}

@end
