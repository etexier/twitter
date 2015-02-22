//
//  TwitterClient.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"


@import Foundation;


FOUNDATION_EXPORT NSString * const TwitterClientErrorDomain;

FOUNDATION_EXPORT NSString * const TwitterClientDidLogInNotification;
FOUNDATION_EXPORT NSString * const TwitterClientDidLogOutNotification;
FOUNDATION_EXPORT NSString * const kTwitterClientOAuthCallbackURL;


#pragma mark -
@interface TwitterClient : NSObject

@property (nonatomic, assign, readonly, getter = isAuthorized) BOOL authorized;

#pragma mark Initialization
+ (instancetype)createWithConsumerKey:(NSString *)apiKey secret:(NSString *)secret;
+ (instancetype)sharedInstance;

#pragma mark Authorization
- (BOOL)isAuthorized;
+ (BOOL)isAuthorizationCallbackURL:(NSURL *)url;
- (void)authorize;
- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url;
- (void)deAuthorize;

#pragma mark Tweets operations
- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion;
- (void)updateStatus:(NSString *)text completion:(void (^)(NSArray *, NSError *))completion;
- (void)retweet:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *))completion;
- (void)replyTo:(NSString *)id completion:(void (^)(NSArray *, NSError *))completion;

@end