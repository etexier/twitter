//
// Created by Emmanuel Texier on 2/24/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tweet;
@class NewTweetViewController;


@protocol NewTweetViewControllerDelegate <NSObject>
- (void) newTweetViewController:(NewTweetViewController *) controller sentTweet:(Tweet *) tweet;
@end