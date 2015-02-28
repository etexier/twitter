//
//  TwitterClient.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Mantle/MTLJSONAdapter.h>
#import "TwitterClient.h"
#import "BDBOAuth1SessionManager.h"
#import "NSDictionary+BDBOAuth1Manager.h"
#import "Tweet.h"

// internal key used to store current user
static NSString *const kCurrentUserKey = @"kTwitterClientCurrentUserKey";

// internal
static NSString *const kTwitterClientAPIURL = @"https://api.twitter.com/1.1/";


// send post or reply
static NSString *const kUpdateStatusRequest = @"statuses/update.json";
// ex: POST https://api.twitter.com/1.1/statuses/retweet/:id.json
static NSString *const kRetweetRequest = @"statuses/retweet/:id.json";
// ex: POST https://api.twitter.com/1.1/statuses/destroy/:id.json
static NSString *const kDestroyRequest = @"statuses/destroy/:id.json";

// ex: GET https://api.twitter.com/1.1/users/show.json?screen_name=rsarver
static NSString *const kUsersShowRequest = @"users/show.json";
// ex: GET https://api.twitter.com/1.1/account/verify_credentials.json
static NSString *const kAccountInfoRequest = @"account/verify_credentials.json";

// ex:POST https://api.twitter.com/1.1/favorites/destroy.json?id=243138128959913986
static NSString *const kUnfavoriteRequest = @"favorites/destroy.json?id=:id";

// ex: POST https://api.twitter.com/1.1/favorites/create.json?id=243138128959913986
static NSString *const kFavoriteRequest = @"favorites/create.json?id=:id";

// ex: GET https://api.twitter.com/1.1/statuses/show.json?id=210462857140252672
static NSString *const kShowTweetRequest = @"statuses/show.json";

// ex: GET https://dev.twitter.com/rest/reference/get/statuses/retweets_of_me.json
static NSString *const kReTweetsOfMeRequest = @"statuses/retweets_of_me.json";

// ex: GET https://api.twitter.com/1.1/statuses/retweets/509457288717819904.js
static NSString *const kReTweetsForTweetRequest = @"statuses/retweets/:id.json";

// exported
NSString *const TwitterClientErrorDomain = @"TwitterClientErrorDomain";

NSString *const TwitterClientDidSignInNotification = @"TwitterClientDidLogInNotification";
NSString *const TwitterClientDidSignOutNotification = @"TwitterClientDidLogOutNotification";

NSString *const kTwitterClientOAuthAuthorizeURL = @"https://api.twitter.com/oauth/authorize";
NSString *const kTwitterClientOAuthCallbackURL = @"etexiertwitter://authorize";
NSString *const kTwitterClientOAuthRequestTokenPath = @"/oauth/request_token";
NSString *const kTwitterClientOAuthAccessTokenPath = @"/oauth/access_token";

// GET timeline query params are 'count' and 'max_id'
NSString *const kTwitterClientHomeTimelinePath = @"statuses/home_timeline.json";
// doc: https://dev.twitter.com/rest/reference/get/statuses/mentions_timeline
// ex: GET https://api.twitter.com/1.1/statuses/mentions_timeline.json?count=2&since_id=14927799
NSString *const kTwitterClientMentionsTimelinePath = @"statuses/mentions_timeline.json";
// doc: https://dev.twitter.com/rest/reference/get/statuses/user_timeline
// ex: GET https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=twitterapi&count=2&exclude_replies=false
NSString *const kTwitterClientProfileTimelinePath = @"statuses/user_timeline.json";



#pragma mark -

@interface TwitterClient ()

@property(nonatomic) BDBOAuth1SessionManager *networkManager;
@property(nonatomic, strong, readwrite) User *currentUser;
#pragma mark - init

- (id)initWithConsumerKey:(NSString *)key secret:(NSString *)secret;


#pragma mark - private utility methods

- (void)postWithQuery:(NSString *)query completion:(void (^)(NSDictionary *, NSError *))completion;


- (void)listWithQuery:(NSString *)query parameters:(NSDictionary *)params completion:(void (^)(NSArray *, NSError *))completion;

- (void)getWithQuery:(NSString *)query parameters:(NSDictionary *)params completion:(void (^)(NSDictionary *, NSError *))completion;
@end

#pragma mark -

@implementation TwitterClient

#pragma mark - init
static TwitterClient *_sharedInstance = nil;

+ (instancetype)createWithConsumerKey:(NSString *)key
                               secret:
                                       (NSString *)secret {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] initWithConsumerKey:key secret:secret];
    });

    return _sharedInstance;
}

- (id)initWithConsumerKey:(NSString *)key
                   secret:
                           (NSString *)secret {
    self = [super init];

    if (self) {
        NSURL *baseURL = [NSURL URLWithString:kTwitterClientAPIURL];

        _networkManager = [[BDBOAuth1SessionManager alloc] initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    }

    return self;
}

+ (instancetype)sharedInstance {
    NSAssert(_sharedInstance, @"TwitterClient is not initialized. Call [TwitterClient createWithConsumerKey:secret:] first.");

    return _sharedInstance;
}


#pragma mark Authorization

+ (BOOL)isAuthorizationCallbackURL:(NSURL *)url {
    NSURL *callbackURL = [NSURL URLWithString:kTwitterClientOAuthCallbackURL];

    return _sharedInstance && [url.scheme isEqualToString:callbackURL.scheme] && [url.host isEqualToString:callbackURL.host];
}

- (BOOL)isAuthorized {
    return self.networkManager.authorized;
}

- (void)authorize {
    [self.networkManager fetchRequestTokenWithPath:kTwitterClientOAuthRequestTokenPath
                                            method:@"POST"
                                       callbackURL:[NSURL URLWithString:kTwitterClientOAuthCallbackURL]
                                             scope:nil
                                           success:^(BDBOAuth1Credential *requestToken) {
                                               // Perform Authorization via MobileSafari
                                               NSString *authURLString = [kTwitterClientOAuthAuthorizeURL stringByAppendingFormat:@"?oauth_token=%@", requestToken.token];
                                               NSLog(@"Got request token!");
                                               [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURLString]];
                                           }
                                           failure:^(NSError *error) {
                                               NSLog(@"Error: %@", error.localizedDescription);

                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                               message:@"Could not acquire OAuth request token. Please try again later."
                                                                              delegate:self
                                                                     cancelButtonTitle:@"Dismiss"
                                                                     otherButtonTitles:nil] show];
                                               });
                                           }];
}

- (BOOL)handleAuthorizationCallbackURL:(NSURL *)url {
    NSDictionary *parameters = [NSDictionary bdb_dictionaryFromQueryString:url.query];

    if (parameters[BDBOAuth1OAuthTokenParameter] && parameters[BDBOAuth1OAuthVerifierParameter]) {
        [self.networkManager fetchAccessTokenWithPath:kTwitterClientOAuthAccessTokenPath
                                               method:@"POST"
                                         requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
                    NSLog(@"Received access token for %@", accessToken.userInfo[@"screen_name"]);
                    [self showSignedInUserInfoWithCompletion:^(NSDictionary *userDictionary, NSError *error) {
                        NSLog(@"Getting user info for logged in user %@", accessToken.userInfo[@"screen_name"]);
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);

                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Could not get current user info. Try again later."
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil] show];
                                return;
                            });
                        }
                        // notify all listeners
                        [[NSNotificationCenter defaultCenter] postNotificationName:TwitterClientDidSignInNotification
                                                                            object:self
                                                                          userInfo:userDictionary];

                    }];

                }
                                              failure:^(NSError *error) {
                                                  NSLog(@"Error: %@", error.localizedDescription);

                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"Could not acquire OAuth access token. Please try again later."
                                                                                 delegate:self
                                                                        cancelButtonTitle:@"Dismiss"
                                                                        otherButtonTitles:nil] show];
                                                  });
                                              }];

        return YES;
    }

    return NO;
}

- (void)deAuthorize {
    [self.networkManager deauthorize];

    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterClientDidSignOutNotification object:self];
}

#pragma mark Tweets

// generic load timeline
- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion
                              path:(NSString *)path
                          beforeId:(NSString *)id
                           afterId:(NSString *)minId {
    [self loadTimelineWithCompletion:completion path:path screenName:nil beforeId:id afterId:minId];
}

// generare load timeline with screenname
- (void)loadTimelineWithCompletion:(void (^)(NSArray *tweets, NSError *error))completion
                              path:(NSString *)path
                        screenName:(NSString *) screenName
                          beforeId:(NSString *)id
                           afterId:(NSString *)minId {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"count"] = @"20";
    if (id) {
        params[@"max_id"] = id;
    }
    if (minId) {
        params[@"since_id"] = minId;
    }

    if (screenName) {
        params[@"screen_name"] = screenName;
    }
    [self listWithQuery:path parameters:params completion:completion];
}

- (void)updateStatus:(NSString *)text
          completion:
                  (void (^)(NSDictionary *, NSError *error))completion {
    NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *query = [NSString stringWithFormat:@"%@?status=%@", kUpdateStatusRequest, encodedText];
    [self postWithQuery:query completion:completion];
}

- (void)favorite:(NSString *)tweetId
      completion:
              (void (^)(NSDictionary *, NSError *))completion {
    NSString *query = [kFavoriteRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];

}


- (void)unfavorite:(NSString *)tweetId
        completion:
                (void (^)(NSDictionary *, NSError *))completion {
    NSString *query = [kUnfavoriteRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}


- (void)retweet:(NSString *)tweetId
     completion:
             (void (^)(NSDictionary *, NSError *))completion {
    NSString *query = [kRetweetRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}

- (void)listRetweetsOfMeWithCompletion:(void (^)(NSArray *, NSError *error))completion {
    NSString *query = kReTweetsOfMeRequest;
    [self listWithQuery:query parameters:nil completion:completion];
}

- (void)listRetweetsForTweetId:(NSString *)tweetId
                    completion:
                            (void (^)(NSArray *, NSError *error))completion {
    NSString *query = [kReTweetsForTweetRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self listWithQuery:query parameters:nil completion:completion];

}

// Warning! you can only destroy your own tweets or retweet. Otherwise API returns "Forbidden 403" errors
- (void)destroyTweet:(NSString *)tweetId
          completion:
                  (void (^)(NSDictionary *, NSError *))completion {
    NSString *query = [kDestroyRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}


- (void)replyTo:(NSString *)id
  withTweetText:
          (NSString *)text
     completion:
             (void (^)(NSDictionary *, NSError *error))completion {
    NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *query = [NSString stringWithFormat:@"%@?status=%@&in_reply_to_status_id=%@", kUpdateStatusRequest, encodedText, id];
    [self postWithQuery:query completion:completion];
}

- (void)showTweet:(NSString *)tweetId
       completion:
               (void (^)(NSDictionary *, NSError *))completion {
    NSDictionary *params = @{@"id" : tweetId};
    [self getWithQuery:kShowTweetRequest parameters:params completion:completion];
};


- (void)showUserForScreenName:(NSString *)screenName
                   completion:
                           (void (^)(NSDictionary *dictionary, NSError *error))completion {
    NSDictionary *params = @{@"screen_name" : screenName};
    [self getWithQuery:kUsersShowRequest parameters:params completion:completion];
}

- (void)showSignedInUserInfoWithCompletion:(void (^)(NSDictionary *dictionary, NSError *error))completion {
    [self getWithQuery:kAccountInfoRequest parameters:nil completion:completion];
}

+ (void)parseTweetsFromListResponse:(id)responseObject
                         completion:
                                 (void (^)(NSMutableArray *, NSError *))completion {

    if (![responseObject isKindOfClass:[NSArray class]]) {
        NSError *error = [NSError errorWithDomain:TwitterClientErrorDomain
                                             code:1000
                                         userInfo:@{NSLocalizedDescriptionKey : @"Unexpected response received from Twitter API."}];

        return completion(nil, error);
    }

    NSArray *response = responseObject;

    NSMutableArray *tweets = [NSMutableArray array];

    for (NSDictionary *tweetInfo in response) {
        Tweet *tweet = [[Tweet alloc] initWithJson:tweetInfo];
        [tweets addObject:tweet];
    }
    NSLog(@"Created array of %lu tweet instances...", (unsigned long) tweets.count);

    completion(tweets, nil);
}


#pragma mark - private utility methods

- (void)listWithQuery:(NSString *)query
           parameters:
                   (NSDictionary *)params
           completion:
                   (void (^)(NSArray *, NSError *))completion {
    [self.networkManager GET:query
                  parameters:params
                     success:^(NSURLSessionDataTask *task, id responseObject) {
//                         NSLog(@"GET LIST  : %@ with params %@ SUCCESS. Response:%@", query, params, responseObject);
                         completion(responseObject, nil);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"GET LIST: %@ with params %@ FAILED", query, params);
                         completion(nil, error);
                     }];

}

- (void)getWithQuery:(NSString *)query
          parameters:
                  (NSDictionary *)params
          completion:
                  (void (^)(NSDictionary *, NSError *))completion {
    [self.networkManager GET:query
                  parameters:params
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"GET : %@ with params %@ SUCCESS. Response:%@", query, params, responseObject);
                         completion(responseObject, nil);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"GET : %@ with params %@ FAILED", query, params);
                         completion(nil, error);
                     }];

}

- (void)postWithQuery:(NSString *)query
           completion:
                   (void (^)(NSDictionary *, NSError *))completion {
    [self.networkManager POST:query
                   parameters:nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          NSLog(@"query : %@ successful", query);
                          completion(responseObject, nil);
                      }
                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                          NSLog(@"query : %@ failed", query);
                          completion(nil, error);
                      }];

}


- (void)loginWithCompletion:(void (^)(User *, NSError *))pFunction {

}
@end
