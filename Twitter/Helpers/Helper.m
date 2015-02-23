//
// Created by Emmanuel Texier on 2/21/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TweetsViewController.h"
#import "NewTweetViewController.h"
#import "Tweet.h"
#import "TweetDetailsViewController.h"
#import "Helper.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"


@implementation Helper
+ (void)fadeInImage:(UIImageView *)imageView url:(NSURL *)url {
    imageView.alpha = 0;
    [imageView setImageWithURL:url];
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:1.0];
    imageView.alpha = 1;
    [UIView commitAnimations];
}


+ (NSString *)calculateTimeAgoTillDate:(NSDate *)date {
    NSDate *now = [NSDate date];
    NSString *timeAgo;
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar]
            components:NSCalendarUnitSecond
              fromDate:date
                toDate:now
               options:0];
    if (timeComponents.second) {
        long secondsAgo = timeComponents.second;
        if (secondsAgo < 60) {
            timeAgo = [NSString stringWithFormat:@"%lus", secondsAgo];
            return timeAgo;
        }

        long minutesAgo = secondsAgo / 60;
        if (minutesAgo < 60) {
            timeAgo = [NSString stringWithFormat:@"%lum", minutesAgo];
            return timeAgo;
        }

        long hoursAgo = secondsAgo / (60 * 60);
        if (hoursAgo < 60) {
            timeAgo = [NSString stringWithFormat:@"%luh", hoursAgo];
            return timeAgo;
        }

        // check n days ago
        long daysAgo = secondsAgo / (60 * 60 * 24);
        if (daysAgo > 0) {
            timeAgo = [NSString stringWithFormat:@"%lud", daysAgo];
            return timeAgo;
        }

    }
    return @"0s";

}


+ (NSString *)calculateLocalDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY hh:mm:ss a"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;

}

+ (void)updateFavoriteImageView:(UIImageView *)imageView tweet:(Tweet *)tweet {
    if (tweet.favorited) {
        imageView.image = [UIImage imageNamed:@"like_on.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"like.png"];
    }
}

+ (void)updateRetweetImageView:(UIImageView *)imageView tweet:(Tweet *)tweet {
    if (tweet.retweeted) {
        imageView.image = [UIImage imageNamed:@"retweet_on.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"retweet.png"];
    }
}

+ (TweetsViewController *)backViewController:(UINavigationController *)nvc {
    NSInteger numberOfViewControllers = nvc.viewControllers.count;
    if (numberOfViewControllers < 2) {
        return nil;
    } else {
        NSUInteger index = (NSUInteger) (numberOfViewControllers - 2);
        return (TweetsViewController *) nvc.viewControllers[index];
    }
}

+ (int)findTweetIndexWithId:(NSString *)id fromTweets:(NSArray *)tweets {
    int found = -1;
    int i;
    for (i = 0; i < [tweets count]; i++) {
        Tweet *t = tweets[i];
        if ([t.id isEqualToString:id]) {
            found = i;
        }
    }
    return found;

}

+ (int)findReTweetIndexWithId:(NSString *)id fromTweets:(NSArray *)tweets {
    int found = -1;
    int i;
    for (i = 0; i < [tweets count]; i++) {
        Tweet *t = tweets[i];
        if ([id isEqualToString:t.originalTweetId]) {
            found = i;
        }
    }
    return found;

}

+ (void)onSwitchRetweetStatusForTweet:(Tweet *)tweet completion:(void (^)(NSString *tweetId, NSError *err))completion {
    if (tweet.retweeted) { // need to destroy retweet
        // must find my retweet id for this tweet id

        // first, get list of my retweets
        [[TwitterClient sharedInstance] listRetweetsOfMeWithCompletion:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"Couldn't find list of retweets. Error:%@", error.localizedDescription);
                completion(nil, error);
                return;
            }

            // parse tweets
            [TwitterClient parseTweetsFromListResponse:array completion:^(NSArray *array1, NSError *error1) {
                if (error) {
                    NSLog(@"Couldn't parse list of retweets. Error:%@", error1.localizedDescription);
                    completion(nil, error1);
                    return;
                }
                // find my retweet for this retweet id
                NSArray *tweets = array1;
                int found = [Helper findReTweetIndexWithId:tweet.id fromTweets:tweets];
                if (found == -1) {
                    NSLog(@"Couldn't find retweeted tweet with id %@", tweet.id);
                    return;
                }

                Tweet *retweet = tweets[(NSUInteger) found];
                // delete my retweet
                [[TwitterClient sharedInstance] destroyTweet:retweet.id completion:^(NSDictionary *array2, NSError *error2) {
                    if (error2) {
                        NSLog(@"Couldn't destroy retweet. Error:%@", error2.localizedDescription);
                    }
                    completion(tweet.id, error2);
                    return;
                }];

            }];
        }];
    } else { // just retweet it
        [[TwitterClient sharedInstance] retweet:tweet.id completion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSLog(@"Couldn't retweet tweet. Error:%@", error.localizedDescription);
            }
            completion(tweet.id, error);
        }];

    }


}

+ (void)switchRetweetStatus:(Tweet *)tweet imageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_main_queue(), ^{
        tweet.retweeted = !tweet.retweeted;
        [Helper updateRetweetImageView:imageView tweet:tweet];
    });

}

+ (void)switchFavoriteStatus:(Tweet *)tweet imageView:(UIImageView *)imageView {
    dispatch_async(dispatch_get_main_queue(), ^{
        tweet.favorited = !tweet.favorited;
        [Helper updateFavoriteImageView:imageView tweet:tweet];
    });
}

+ (void)onSwitchFavoriteStatus:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
    if (tweet.favorited) {
        [[TwitterClient sharedInstance] unfavorite:tweet.id completion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSLog(@"Couldn't unfavorite tweet. Error:%@", error.localizedDescription);
                return;
            }
            completion(tweet.id, error);
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:tweet.id completion:^(NSDictionary *array, NSError *error) {
            if (error) {
                NSLog(@"Couldn't favorite tweet. Error:%@", error.localizedDescription);
                return;
            }
            completion(tweet.id, error);
        }];

    }


}
@end