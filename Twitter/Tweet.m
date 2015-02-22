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
//  Copyright (c) 2014 Bradley David Bergeron
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "Tweet.h"


static NSString *const kTweetTweetTextName = @"text";
static NSString *const kTweetUserInfoName = @"user";
static NSString *const kTweetUserImageURLName = @"profile_image_url";
static NSString *const kTweetUserNameName = @"name";
static NSString *const kTweetCreatedAtName = @"created_at";
static NSString *const kTweetUserScreenNameName = @"screen_name";

#pragma mark -

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        // 1. text
        _tweetText = [dictionary[kTweetTweetTextName] copy];

        // 2. date
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        _createdAt = [dateFormatter dateFromString:[dictionary[kTweetCreatedAtName] copy]];

        NSDictionary *userInfo = dictionary[kTweetUserInfoName];

        // 3. image
        if (userInfo[kTweetUserImageURLName]) {
            NSString *userImageURLString = [userInfo[kTweetUserImageURLName] stringByReplacingOccurrencesOfString:@"_normal"
                                                                                                       withString:@"_bigger"];

            _userImageURL = [NSURL URLWithString:userImageURLString];
        }

        // 4. username
        _userName = userInfo[kTweetUserNameName];

        // 5. screen name
        _userScreenName = userInfo[kTweetUserScreenNameName];
        NSLog(@"Created tweet from %@", self.userScreenName);

//        // 6. retweet info
//        _retweetInfo = userInfo[]
    }

    return self;
}

@end
