//
//  TwitterClient.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TwitterClient.h"
#import "BDBOAuth1SessionManager.h"
#import "NSDictionary+BDBOAuth1Manager.h"
#import "Tweet.h"


// internal
static NSString *const kTwitterClientAPIURL = @"https://api.twitter.com/1.1/";
static NSString *const kTimeLinePath = @"statuses/home_timeline.json?count=10";
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

// exported
NSString *const TwitterClientErrorDomain = @"TwitterClientErrorDomain";

NSString *const TwitterClientDidSignInNotification = @"TwitterClientDidLogInNotification";
NSString *const TwitterClientDidSignOutNotification = @"TwitterClientDidLogOutNotification";

NSString *const kTwitterClientOAuthAuthorizeURL = @"https://api.twitter.com/oauth/authorize";
NSString *const kTwitterClientOAuthCallbackURL = @"etexiertwitter://authorize";
NSString *const kTwitterClientOAuthRequestTokenPath = @"/oauth/request_token";
NSString *const kTwitterClientOAuthAccessTokenPath = @"/oauth/access_token";


#pragma mark -

@interface TwitterClient ()

@property(nonatomic) BDBOAuth1SessionManager *networkManager;
@property(nonatomic, readwrite, copy) NSDictionary *userInfo;

- (id)initWithConsumerKey:(NSString *)key secret:(NSString *)secret;

- (void)postWithQuery:(NSString *)query completion:(void (^)(NSArray *, NSError *))completion;
@end

#pragma mark -

@implementation TwitterClient

#pragma mark Initialization
static TwitterClient *_sharedInstance = nil;

+ (instancetype)createWithConsumerKey:(NSString *)key secret:(NSString *)secret {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] initWithConsumerKey:key secret:secret];
    });

    return _sharedInstance;
}

- (id)initWithConsumerKey:(NSString *)key secret:(NSString *)secret {
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
                                         requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
                                              success:^(BDBOAuth1Credential *accessToken) {
                                                  NSLog(@"Received access token for %@", accessToken.userInfo[@"screen_name"]);
                                                  // notify all listeners
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:TwitterClientDidSignInNotification
                                                                                                      object:self
                                                                                                    userInfo:accessToken.userInfo];
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

- (void)loadTimelineWithCompletion:(void (^)(NSArray *, NSError *))completion {
    [self.networkManager GET:kTimeLinePath
                  parameters:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Time line Response; %@", @"..."); //responseObject);
                         [self parseTweetsFromAPIResponse:responseObject completion:completion];
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Failed to load timeline!");
                         completion(nil, error);
                     }];
}

- (void)updateStatus:(NSString *)text completion:(void (^)(NSArray *, NSError *error))completion {
    NSString *encodedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSString *query = [NSString stringWithFormat:@"%@?status=%@", kUpdateStatusRequest, encodedText];
    [self postWithQuery:query completion:completion];
}

- (void)favorite:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *))completion {
    NSString *query = [kFavoriteRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];

}

- (void) postWithQuery:(NSString *)query completion:(void (^)(NSArray *, NSError *))completion {
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

- (void)unfavorite:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *))completion {
    NSString *query = [kUnfavoriteRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}


- (void)retweet:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *error))completion {
    NSString *query = [kRetweetRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}

- (void)destroyTweet:(NSString *)tweetId completion:(void (^)(NSArray *, NSError *))completion {
    NSString *query = [kDestroyRequest stringByReplacingOccurrencesOfString:@":id" withString:tweetId];
    [self postWithQuery:query completion:completion];
}


- (void)replyTo:(NSString *)id1 completion:(void (^)(NSArray *, NSError *error))completion {
    // TODO: TBI
}

- (void)showTweet:(NSString *)tweetId completion:(void (^)(NSDictionary *, NSError *))completion {
    [self.networkManager GET:kUsersShowRequest
                  parameters:@{@"id" : tweetId}
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Got tweet for  %@: %@", tweetId, responseObject);
                         completion(responseObject, nil);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Failed to get tweet  for %@", tweetId);
                         completion(nil, error);
                     }];

}


- (void)showUserForScreenName:(NSString *)screenName completion:(void (^)(NSDictionary *dictionary, NSError *error))completion {
    //users/show.json?screen_name=rsarver
    [self.networkManager GET:kUsersShowRequest
                  parameters:@{@"screen_name" : screenName}
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Got user info for  %@: %@", screenName, responseObject);
                         completion(responseObject, nil);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Failed to get user info for %@", screenName);
                         completion(nil, error);
                     }];

}

- (void)showSignedInUserInfoWithCompletion:(void (^)(NSDictionary *dictionary, NSError *error))completion {
    // GET https://api.twitter.com/1.1/account/verify_credentials.json
    [self.networkManager GET:kAccountInfoRequest
                  parameters:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Got user info for logged in user: %@", responseObject);
                         completion(responseObject, nil);
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Failed to get user info for logged in user");
                         completion(nil, error);
                     }];

}


- (void)parseTweetsFromAPIResponse:(id)responseObject completion:(void (^)(NSArray *, NSError *))completion {
    if (![responseObject isKindOfClass:[NSArray class]]) {
        NSError *error = [NSError errorWithDomain:TwitterClientErrorDomain
                                             code:1000
                                         userInfo:@{NSLocalizedDescriptionKey : @"Unexpected response received from Twitter API."}];

        return completion(nil, error);
    }


    NSArray *response = responseObject;

    NSMutableArray *tweets = [NSMutableArray array];

    for (NSDictionary *tweetInfo in response) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetInfo];
        [tweets addObject:tweet];
    }
    NSLog(@"Created array of %lu tweet instances...", (unsigned long) tweets.count);

    completion(tweets, nil);
}

@end
