//
// Created by Emmanuel Texier on 2/21/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "Tweet.h"
#import "TweetDetailsViewController.h"
#import "Helper.h"
#import "UIImageView+AFNetworking.h"


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
            timeAgo = [NSString stringWithFormat:@"%lus", secondsAgo ];
            return timeAgo;
        }

        long minutesAgo = secondsAgo/60;
        if (minutesAgo < 60) {
            timeAgo = [NSString stringWithFormat:@"%lum", minutesAgo];
            return timeAgo;
        }

        long hoursAgo = secondsAgo/(60*60);
        if (hoursAgo < 60) {
            timeAgo = [NSString stringWithFormat:@"%luh", hoursAgo];
            return timeAgo;
        }

        // check n days ago
        long daysAgo = secondsAgo / (60*60*24);
        if (daysAgo > 0) {
            timeAgo = [NSString stringWithFormat:@"%lud", daysAgo ];
            return timeAgo;
        }

    }
    return @"0s";

}


+ (NSString *)calculateLocalDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY hh:mm:ss a"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate: date];
    return dateString;

}
+ (void)updateLikeImageView:(UIImageView *) imageView tweet:(Tweet *) tweet {
    if (tweet.favorited) {
        imageView.image = [UIImage imageNamed:@"like_on.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"like.png"];
    }
}

+ (void)updateRetweetImageView:(UIImageView *) imageView tweet:(Tweet *) tweet {
    if (tweet.retweeted) {
        imageView.image = [UIImage imageNamed:@"retweet_on.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"retweet.png"];
    }
}
@end