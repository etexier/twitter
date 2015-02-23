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

#import "Tweet.h"


static NSString *const kTweetTweetTextName = @"text";
static NSString *const kTweetUserInfoName = @"user";
static NSString *const kTweetUserImageURLName = @"profile_image_url";
static NSString *const kTweetUserNameName = @"name";
static NSString *const kTweetCreatedAtName = @"created_at";
static NSString *const kTweetUserScreenNameName = @"screen_name";
static NSString *const kTweetRetweetCountName = @"retweet_count";
static NSString *const kTweetFavoriteCountName = @"favorite_count";
static NSString *const kTweetFavoritedName = @"favorited";
static NSString *const kTweetRetweetedName = @"retweeted";
static NSString *const kTweetIdName = @"id_str";
static NSString *const kTweetOriginalTweetId = @"retweeted_status.id_str";

#pragma mark - implementation class

@implementation Tweet

- (id)initWithDictionary:(NSDictionary *)dictionary {
    NSLog(@"Creating tweet from %@", dictionary);
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

        _favoriteCount = [dictionary[kTweetFavoriteCountName] unsignedIntegerValue];
        _retweetCount = [dictionary[kTweetRetweetCountName] unsignedIntegerValue];
        _favorited = [dictionary[kTweetFavoritedName] boolValue];
        _retweeted = [dictionary[kTweetRetweetedName] boolValue];
        if (_retweeted) {
            _originalTweetId = [dictionary valueForKeyPath:kTweetOriginalTweetId];
        }
        _id = dictionary[kTweetIdName];

        // create user now:


//        // 6. retweet info
//        _retweetInfo = userInfo[]
    }

    return self;
}

@end
