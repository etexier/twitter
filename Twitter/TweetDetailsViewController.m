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
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAgoLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImageView;
@property (weak, nonatomic) IBOutlet UIImageView *retweetImageView;
@property (weak, nonatomic) IBOutlet UIImageView *likeImageView;

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
    self.timeAgoLabel.text = [Helper calculateTimeAgoTillDate:_tweet.createdAt];

    self.tweetLabel.text = _tweet.tweetText;

    [self.replyImageView initWithImage:[UIImage imageNamed:@"reply.png"]];
    [self.retweetImageView initWithImage:[UIImage imageNamed:@"retweet.png"]];
    [self.likeImageView initWithImage:[UIImage imageNamed:@"like.png"]];

    // retweet label is not always there
//        if (_tweet.retweetInfo) {
//            _retweetInfoLabel.text = _tweet.retweetInfo;
//        }

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
