//
// Created by Emmanuel Texier on 2/21/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TimelineViewController.h"
#import "Tweet.h"


@interface Helper : NSObject
+ (void) fadeInImage:(UIImageView *)imageView url:(NSURL *) url;

+ (void)initLayoutForController:(UINavigationController *)controller;


+ (User *) currentUser;
+ (void) setCurrentUser:(User *) user;
+ (UIColor *) twitterBackgroundColor;


+ (NSString *)calculateTimeAgoTillDate:(NSDate *)date;

+ (NSString *)calculateLocalDate:(NSDate *)date;

+ (void)updateFavoriteImageView:(UIImageView *)imageView tweet:(Tweet *)tweet;

+ (void)updateRetweetImageView:(UIImageView *)imageView tweet:(Tweet *)tweet;

+ (TimelineViewController *)backViewController:(UINavigationController *)nvc;

+ (int)findTweetIndexWithId:(NSString *)id fromTweets:(NSArray *)tweets;

+ (int)findReTweetIndexForScreenName:(NSString *)id1 fromTweets:(NSArray *)tweets;

+ (void)onSwitchRetweetStatusForTweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion;

+ (void)onSwitchFavoriteStatus:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion;

+ (CGFloat)statusBarAdjustment:(UIView *)view;

+ (void)updateReplyImageView:(UIImageView *)view tweet:(Tweet *)tweet;

+ (NSDateFormatter *) dateFormatter;
@end
