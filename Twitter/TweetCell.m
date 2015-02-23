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

@interface TweetCell ()

@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *createdTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property(weak, nonatomic) IBOutlet UILabel *retweetInfoLabel;

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

    [self.userImageView setImageWithURL:_tweet.userImageURL];
//    [Helper fadeInImage:self.imageView url:tweet.userImageURL]; // fade in effect


    _userNameLabel.text = _tweet.userName;
    _userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet.userScreenName];
    _tweetTextLabel.text = _tweet.tweetText;

    // retweet label is not always there
    if (_tweet.retweetInfo) {
        _retweetInfoLabel.text = _tweet.retweetInfo;
    }

    self.replyImageView.image = [UIImage imageNamed:@"reply.png"];
    [Helper updateFavoriteImageView:self.likeImageView tweet:_tweet];
    [Helper updateRetweetImageView:self.retweetImageView tweet:_tweet];

    [self registerGestureOnImageView:self.likeImageView selector:@selector(onSwitchFavoriteStatus)];
    [self registerGestureOnImageView:self.retweetImageView selector:@selector(onSwitchRetweetStatus)];
    [self registerGestureOnImageView:self.replyImageView selector:@selector(onSelectReplyImage)];

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
    // TODO
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
