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

@interface TweetCell ()

@property(weak, nonatomic) IBOutlet UIImageView *userImageView;
@property(weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *userScreenNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *createdTimeLabel;
@property(weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property(weak, nonatomic) IBOutlet UILabel *retweetInfoLabel;


// buttons
@property(weak, nonatomic) IBOutlet UIButton *retweetButton;
@property(weak, nonatomic) IBOutlet UIButton *replyButton;
@property(weak, nonatomic) IBOutlet UIButton *favoriteButton;

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
    _userScreenNameLabel.text = [NSString stringWithFormat:@"@%@", _tweet.userScreenName ];
    _tweetTextLabel.text = _tweet.tweetText;

    // retweet label is not always there
    if (_tweet.retweetInfo) {
        _retweetInfoLabel.text = _tweet.retweetInfo;
    }

    // Calculate how long ago
    NSDate *now = [NSDate date];
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar]
            components:NSCalendarUnitSecond
              fromDate:_tweet.createdAt
                toDate:now
               options:0];
    if (timeComponents.second) {
        long secondsAgo = timeComponents.second;
        if (secondsAgo < 60) {
            _createdTimeLabel.text = [NSString stringWithFormat:@"%lus", secondsAgo ];
            return;
        }
        
        long minutesAgo = (long) (secondsAgo/60);
        if (minutesAgo < 60) {
            _createdTimeLabel.text = [NSString stringWithFormat:@"%lum", minutesAgo];
            return;
        }

        long hoursAgo = (long) (secondsAgo/(60*60));
        if (hoursAgo < 60) {
            _createdTimeLabel.text = [NSString stringWithFormat:@"%luh", hoursAgo];
            return;
        }

        // check n days ago
        long daysAgo = (long) (secondsAgo / (60*60*24));
        if (daysAgo > 0) {
            _createdTimeLabel.text = [NSString stringWithFormat:@"%lud", daysAgo ];
            return;
        }
        
        
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.userNameLabel.preferredMaxLayoutWidth = self.userNameLabel.frame.size.width;

}

@end
