//
//  TwitterClient.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TwitterClient.h"

NSString *const kTwitterConsumerKey = @"jmyioWQaC58W2skNWR9zTy9wT";
NSString *const kTwitterConsumerSecret = @"eY5P6qONhcJc0T2yXrhFcA0zsYIEyI5zgjzdf6b05ynDf0ch9P";
NSString *const kTwitterBaseURL = @"https://api.twitter.com/1.1";

@implementation TwitterClient

+(TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        // in dispatch once to make it thread-safe
        if (instance == nil) {
            instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseURL]
                                         consumerKey:kTwitterConsumerKey
                                      consumerSecret:kTwitterConsumerKey];
        }
    });
    return instance;
}

@end
