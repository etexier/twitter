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
static NSString *const kTimeLinePath = @"statuses/home_timeline.json?count=100";


// exported
NSString *const TwitterClientErrorDomain = @"TwitterClientErrorDomain";

NSString *const TwitterClientDidLogInNotification = @"TwitterClientDidLogInNotification";
NSString *const TwitterClientDidLogOutNotification = @"TwitterClientDidLogOutNotification";

NSString *const kTwitterClientOAuthAuthorizeURL = @"https://api.twitter.com/oauth/authorize";
NSString *const kTwitterClientOAuthCallbackURL = @"etexiertwitter://authorize";
NSString *const kTwitterClientOAuthRequestTokenPath = @"/oauth/request_token";
NSString *const kTwitterClientOAuthAccessTokenPath = @"/oauth/access_token";

#pragma mark -

@interface TwitterClient ()

@property(nonatomic) BDBOAuth1SessionManager *networkManager;

- (id)initWithConsumerKey:(NSString *)key secret:(NSString *)secret;

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
    NSAssert(_sharedInstance, @"TwitterClient not initialized. [TwitterClient createWithConsumerKey:secret:] must be called first.");

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
                                                  NSLog(@"Received access token!");
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:TwitterClientDidLogInNotification
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

    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterClientDidLogOutNotification object:self];
}

#pragma mark Tweets

- (void)loadTimelineWithCompletion:(void (^)(NSArray *, NSError *))completion {
    [self.networkManager GET:kTimeLinePath
                  parameters:nil
                     success:^(NSURLSessionDataTask *task, id responseObject) {
                         NSLog(@"Time line Response; %@", responseObject);
                         [self parseTweetsFromAPIResponse:responseObject completion:completion];
                     }
                     failure:^(NSURLSessionDataTask *task, NSError *error) {
                         NSLog(@"Failed to load timeline!");
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

    NSLog(@"Creating array of tweet instances...");

    NSArray *response = responseObject;

    NSMutableArray *tweets = [NSMutableArray array];

    for (NSDictionary *tweetInfo in response) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetInfo];
        [tweets addObject:tweet];
    }

    completion(tweets, nil);
}


@end
