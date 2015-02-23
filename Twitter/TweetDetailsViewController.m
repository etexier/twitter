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
#import "TwitterClient.h"
#import "TweetsViewController.h"

@interface TweetDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoritedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

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

    [self.userImageView setImageWithURL:_tweet.userImageURL];
//    [Helper fadeInImage:self.imageView url:tweet.userImageURL]; // fade in effect
    // round image
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0f;
    self.userImageView.clipsToBounds = YES;


    self.userNameLabel.text = _tweet.userName;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet.userScreenName];

    // Calculate how long ago
    self.timeAgoLabel.text = [NSString stringWithFormat:@"%@ ago", [Helper calculateTimeAgoTillDate:_tweet.createdAt]];
    self.dateLabel.text = [Helper calculateLocalDate:_tweet.createdAt];
    self.tweetLabel.text = _tweet.tweetText;
    self.tweetLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tweetLabel.layer.cornerRadius = 4.0;
    self.tweetLabel.layer.borderWidth = 1;
    UIEdgeInsets insets = {0,5,0,5};

    [self.tweetLabel drawTextInRect:UIEdgeInsetsInsetRect(self.tweetLabel.layer.visibleRect, insets)];


    self.retweetLabel.text = [NSString stringWithFormat:@"RETWEETS %lu", (unsigned long) _tweet.retweetCount];
    self.favoritedLabel.text = [NSString stringWithFormat:@"FAVORITES %lu", (unsigned long) _tweet.favoriteCount];

    self.replyImageView.image = [UIImage imageNamed:@"reply.png"];
    [Helper updateLikeImageView:self.likeImageView tweet:_tweet];
    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];

    [self registerGestureOnImageView:self.likeImageView selector:@selector(onSelectLikeImage)];
    [self registerGestureOnImageView:self.retweetImageView selector:@selector(onSelectRetweetImage)];
    [self registerGestureOnImageView:self.replyImageView selector:@selector(onSelectReplyImage)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) registerGestureOnImageView:(UIImageView *) imageView selector:(SEL) selector {

    [imageView setUserInteractionEnabled:YES];

    // select
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    singleTap.numberOfTapsRequired = 1;

    [imageView addGestureRecognizer:singleTap];

}

-(void)onSelectReplyImage{
    NSLog(@"single Tap on reply");
    // TODO
}

-(void)onSelectRetweetImage{
    NSLog(@"single Tap on retweet");
    _tweet.retweeted = !_tweet.retweeted;
    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
    if (!_tweet.retweeted) {

        [[TwitterClient sharedInstance] destroyTweet:_tweet.id completion:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                // undo model
                _tweet.retweeted = !_tweet.retweeted;
                // undo UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
                });

            } else {
                TweetsViewController *vc = [Helper backViewController:self.navigationController];
                [vc reloadTweet:_tweet.id];
                [self reloadTweet:_tweet.id];

                // success!
            }
        }];
    } else {
        [[TwitterClient sharedInstance] retweet:_tweet.id completion:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                // undo model
                _tweet.retweeted = !_tweet.retweeted;
                // undo UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
                });

            } else {
                // success!
            }
        }];

    }
}

- (void)reloadTweet:(NSString *)id {
    // TBI

}

- (void)onSelectLikeImage{
    NSLog(@"single Tap on favorite");
    _tweet.favorited = !_tweet.favorited;
    [Helper updateLikeImageView:self.likeImageView tweet:_tweet];
    if (!_tweet.favorited) {

        [[TwitterClient sharedInstance] unfavorite:_tweet.id completion:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                // undo model
                _tweet.favorited = !_tweet.favorited;
                // undo UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
                });

            } else {
                // success!
            }
        }];
    } else {
        [[TwitterClient sharedInstance] favorite:_tweet.id completion:^(NSArray *array, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                // undo model
                _tweet.favorited = !_tweet.favorited;
                // undo UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Error"
                                                message:error.localizedDescription
                                               delegate:self
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
                });

            } else {
                // success!
            }
        }];

    }
}


@end
