//
//  TwitterClient.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"


@import Foundation;@class User;


FOUNDATION_EXPORT NSString *const TwitterClientErrorDomain;

FOUNDATION_EXPORT NSString *const TwitterClientDidSignInNotification;
FOUNDATION_EXPORT NSString *const TwitterClientDidSignOutNotification;
FOUNDATION_EXPORT NSString *const kTwitterClientOAuthCallbackURL;


FOUNDATION_EXPORT NSString *const kTwitterClientHomeTimelinePath;
FOUNDATION_EXPORT NSString *const kTwitterClientMentionsTimelinePath;
FOUNDATION_EXPORT NSString *const kTwitterClientProfileTimelinePath;


@interface TwitterClient : NSObject
#pragma mark - properties

@property(nonatomic, assign, readonly, getter = isAuthorized) BOOL authorized;

#pragma mark - initialization

+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret;

+ (instancetype)sharedInstance;

#pragma mark - authorization

- (BOOL)isAuthorized;

+ (BOOL)isAuthorizationCallbackURL:(NSURL *)url;

+ (void)parseTweetsFromListResponse:(id)responseObject completion:(void (^)(NSMutableArray *, NSError *))completion;

- (void)authorize;

- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url;

- (void)deAuthorize;

#pragma mark - tweets operations

- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion path:(NSString *)path beforeId:(NSString *)id1 afterId:(NSString *)minId;

- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion path:(NSString *)path screenName:(NSString *)screenName beforeId:(NSString *)id1 afterId:(NSString *)minId;

- (void)updateStatus:(NSString *)text completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)favorite:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)unfavorite:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)retweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)listRetweetsOfMeWithCompletion:(void (^)(NSArray *, NSError *error))completion;

- (void)listRetweetsForTweetId:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *error))completion;

- (void)destroyTweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)replyTo:(NSString *)id withTweetText:(NSString *)text completion:(void (^)(NSDictionary *, NSError *error))completion;

- (void)showTweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)showUserForScreenName:(NSString *)screenName completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)showSignedInUserInfoWithCompletion:(void (^)(NSDictionary *dictionary, NSError *error))completion;

- (void)loginWithCompletion:(void (^)(User *, NSError *))pFunction;
@end