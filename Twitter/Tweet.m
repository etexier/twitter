//
//  Tweet.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//
//
//  Tweet.m
//

#import <Mantle/MTLJSONAdapter.h>
#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "NewTweetViewController.h"
#import "Tweet.h"
#import "Helper.h"
#import "User.h"

@interface Tweet () <MTLJSONSerializing>

+ (NSValueTransformer *)createdAtJSONTransformer;

+ (NSValueTransformer *)userJSONTransformer;
@end

#pragma mark - implementation class

@implementation Tweet
#pragma mark -  Mantle mapping

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"id" : @"id_str",
            @"text" : @"text",
            @"createdAt" : @"created_at",
            @"user" : @"user",
            @"favoriteCount" : @"favorite_count",
            @"retweetCount" : @"retweet_count",
            @"favorited" : @"favorited",
            @"retweeted" : @"retweeted"
    };
}

#pragma mark - init

- (instancetype)initWithJson:(NSDictionary *)dictionary {
    NSMutableDictionary *filteredDictionary = [NSMutableDictionary dictionary];
    NSArray *allKeys = [[Tweet JSONKeyPathsByPropertyKey] allValues];
    for (NSString *key in allKeys) {
        filteredDictionary[key] = dictionary[key];
    }
    NSLog(@"filteredDictionary : \n%@", filteredDictionary);
    self = [MTLJSONAdapter modelOfClass:Tweet.class fromJSONDictionary:filteredDictionary error:nil];
    return self;
}

- (instancetype)initFromCurrentUserTweetText:(NSString *)text {
    self = [super init];
    if (self) {
        _id = [NSString stringWithFormat:@"%llu", ULLONG_MAX];
        _text = text;
        _createdAt = [NSDate date];
        _favoriteCount = 0;
        _retweetCount = 0;
        _retweeted = NO;
        _user = [Helper currentUser];
    }
    return self;

}


#pragma mark - Mantle transformers


// transformer for createdAt date
+ (NSValueTransformer *)createdAtJSONTransformer {
    NSDateFormatter *dateFormatter = [Helper dateFormatter];
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [dateFormatter dateFromString:str];
    }                                                    reverseBlock:^(NSDate *date) {
        return [dateFormatter stringFromDate:date];
    }];
}

// User transformer
+ (NSValueTransformer *)userJSONTransformer {
    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:User.class];
}


@end
