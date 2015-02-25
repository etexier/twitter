//
//  TweetCell.m
//  Yelp
//
//  Created by Emmanuel Texier on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "Helper.h"
#import "TwitterClient.h"
#import "NewTweetViewController.h"

@interface TweetCell ()

@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *createdTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@property(weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property(weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property(weak, nonatomic) IBOutlet UIImageView *likeImageView;


@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code

    self.userNameLabel.preferredMaxLayoutWidth = self.userNameLabel.frame.size.width;

    // round image
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2.0f;
    self.userImageView.clipsToBounds = YES;

    // for performance 
    self.userImageView.layer.shouldRasterize = YES;
    self.userImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];

    [self prepareForReuse];
}

- (void)prepareForReuse {
    self.userImageView.image = nil;
    self.userNameLabel.text = @"";
    self.userScreenNameLabel.text = @"@";
    self.tweetTextLabel.text = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;

    [self.userImageView setImageWithURL:_tweet.user.profileImageUrl];
//    [Helper fadeInImage:self.imageView url:tweet.user.profileImageUrl]; // fade in effect


    _userNameLabel.text = _tweet.user.name;
    _userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet.user.screenName];
    _tweetTextLabel.text = _tweet.text;

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



    // Calculate how long ago
    _createdTimeLabel.text = [Helper calculateTimeAgoTillDate:_tweet.createdAt];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.userNameLabel.preferredMaxLayoutWidth = self.userNameLabel.frame.size.width;

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
    [Helper updateReplyImageView:self.replyImageView tweet:_tweet];
    [self onReplyTweet];
}

- (void)onReplyTweet {
    if (![[TwitterClient sharedInstance] isAuthorized]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"You must sign in to tweet"
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
        return;
    }
    NewTweetViewController *vc = [[NewTweetViewController alloc] initAsReplyTo:_tweet.user.screenName forTweetId:_tweet.id
                                                                      delegate:self.delegate];
    UITableView *tv = (UITableView *) self.superview.superview;
    UITableViewController *tvc = (UITableViewController *) tv.dataSource;
    [tvc.navigationController pushViewController:vc animated:YES];
}


- (void)onSwitchRetweetStatus {
    NSLog(@"single Tap on retweet");
    [Helper onSwitchRetweetStatusForTweet:_tweet completion:^(NSString *string, NSError *error) {
        if (error) {
            NSLog(@"Couldn't switch retweet status");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            _tweet.retweeted = !_tweet.retweeted;
            [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];
        });
    }];
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
        });
    }];
}


@end
