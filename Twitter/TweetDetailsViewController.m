//
//  TweetDetailsViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "Tweet.h"
#import "Helper.h"
#import "UIImageView+AFNetworking.h"

@interface TweetDetailsViewController ()
@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property(weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property(weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property(weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property(weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property(weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property(weak, nonatomic) IBOutlet UILabel *favoritedLabel;
@property(weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation TweetDetailsViewController

- (id)initWithTweet:(Tweet *)tweet {
    self = [super init];
    if (self) {
        _tweet = tweet;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tweet";

    [self.userImageView setImageWithURL:_tweet.user.profileImageUrl];
//    [Helper fadeInImage:self.imageView url:tweet.user.profileImageUrl]; // fade in effect
    // round image
    self.userImageView.layer.cornerRadius = 5; // self.userImageView.frame.size.width / 2.0f;
    self.userImageView.clipsToBounds = YES;


    self.userNameLabel.text = _tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet.user.screenName];

    // Calculate how long ago
    self.timeAgoLabel.text = [NSString stringWithFormat:@"%@ ago", [Helper calculateTimeAgoTillDate:_tweet.createdAt]];
    self.dateLabel.text = [Helper calculateLocalDate:_tweet.createdAt];
    self.tweetLabel.text = _tweet.text;
    self.tweetLabel.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.tweetLabel.layer.cornerRadius = 4.0;
//    self.tweetLabel.layer.borderWidth = 1;
    UIEdgeInsets insets = {0, 5, 0, 5};

    [self.tweetLabel drawTextInRect:UIEdgeInsetsInsetRect(self.tweetLabel.layer.visibleRect, insets)];


    [self renderCounters];

    if ([[Helper currentUser].screenName isEqualToString:_tweet.user.screenName]) {
        // no reply is possible
        self.replyImageView.hidden = YES;
        self.replyImageView.userInteractionEnabled = NO;
        self.retweetImageView.hidden = YES;
        self.retweetImageView.userInteractionEnabled = NO;
    } else {
        self.replyImageView.hidden = NO;
        self.replyImageView.userInteractionEnabled = YES;
        [Helper updateReplyImageView:self.replyImageView tweet:_tweet];
        [self registerGestureOnImageView:self.replyImageView selector:@selector(onSelectReplyImage)];

        self.retweetImageView.hidden = NO;
        self.retweetImageView.userInteractionEnabled = YES;
        [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
        [self registerGestureOnImageView:self.retweetImageView selector:@selector(onSwitchRetweetStatus)];

    }
    if ([self.tweet.id isEqualToString:[NSString stringWithFormat:@"%llu", ULLONG_MAX]]) {
        // always supported
        self.likeImageView.hidden = YES;
        self.likeImageView.userInteractionEnabled = NO;

    } else {
        // always supported
        self.likeImageView.hidden = NO;
        self.likeImageView.userInteractionEnabled = YES;
        [Helper updateFavoriteImageView:self.likeImageView tweet:_tweet];
        [self registerGestureOnImageView:self.likeImageView selector:@selector(onSwitchFavoriteStatus)];

    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerGestureOnImageView:(UIImageView *)imageView selector:(SEL)selector {

    [imageView setUserInteractionEnabled:YES];

    // select
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    singleTap.numberOfTapsRequired = 1;

    [imageView addGestureRecognizer:singleTap];

}

- (void)onSelectReplyImage {
    NSLog(@"single Tap on reply");
    // TODO: push to new controller
    [Helper updateReplyImageView:self.replyImageView tweet:_tweet];
}

- (void)onSwitchRetweetStatus {
    NSLog(@"single Tap on retweet");
    [Helper onSwitchRetweetStatusForTweet:_tweet completion:^(NSString *string, NSError *error) {
        if (error) {
            NSLog(@"Couldn't switch retweet status");
            return;
        }
        // success!
        dispatch_async(dispatch_get_main_queue(), ^{
            _tweet.retweeted = !_tweet.retweeted;
            [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
            if (_tweet.retweeted) {
                _tweet.retweetCount = _tweet.retweetCount + 1;
            } else {
                _tweet.retweetCount = _tweet.retweetCount - 1;

            }
            [self renderCounters];;
        });


    }];
}


- (void)renderCounters {
    self.retweetLabel.text = [NSString stringWithFormat:@"RETWEETS %lu", (unsigned long) _tweet.retweetCount];
    self.favoritedLabel.text = [NSString stringWithFormat:@"FAVORITES %lu", (unsigned long) _tweet.favoriteCount];
//    TimelineViewController *vc = [Helper backViewController:self.navigationController];
//    [vc reloadSingleTweetById:id];
}

- (void)onSwitchFavoriteStatus {
    NSLog(@"single Tap on favorite");
    [Helper onSwitchFavoriteStatus:_tweet completion:^(NSString *string, NSError *error) {
        if (error) {
            NSLog(@"Couldn't switch favorite status");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _tweet.favorited = !_tweet.favorited;
            [Helper updateFavoriteImageView:self.likeImageView tweet:_tweet];
            if (_tweet.favorited) {
                _tweet.favoriteCount = _tweet.favoriteCount + 1;
            } else {
                _tweet.favoriteCount = _tweet.favoriteCount - 1;

            }

            [self renderCounters];
        });
    }];
}


@end
