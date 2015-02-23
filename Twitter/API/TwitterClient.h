//
//  TwitterClient.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"


@import Foundation;


FOUNDATION_EXPORT NSString *const TwitterClientErrorDomain;

FOUNDATION_EXPORT NSString *const TwitterClientDidSignInNotification;
FOUNDATION_EXPORT NSString *const TwitterClientDidSignOutNotification;
FOUNDATION_EXPORT NSString *const kTwitterClientOAuthCallbackURL;


@interface TwitterClient : NSObject
#pragma mark - properties

@property(nonatomic, assign, readonly, getter = isAuthorized) BOOL authorized;

#pragma mark - initialization

+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret;

+ (instancetype)sharedInstance;

#pragma mark - authorization

- (BOOL)isAuthorized;

+ (BOOL)isAuthorizationCallbackURL:(NSURL *)url;

+ (void)parseTweetsFromListResponse:(id)responseObject completion:(void (^)(NSArray *, NSError *))completion;

- (void)authorize;

- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url;

- (void)deAuthorize;

#pragma mark - tweets operations

- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion;

- (void)updateStatus:(NSString *)text completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)favorite:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)unfavorite:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)retweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)listRetweetsOfMeWithCompletion:(void (^)(NSArray *, NSError *error))completion;

- (void)destroyTweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)replyTo:(NSString *)id completion:(void (^)(NSArray *, NSError *))completion;

- (void)showTweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)showUserForScreenName:(NSString *)screenName completion:(void (^)(NSDictionary *, NSError *))completion;

- (void)showSignedInUserInfoWithCompletion:(void (^)(NSDictionary *dictionary, NSError *error))completion;
@end