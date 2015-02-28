//
//  TweetCell.h
//
//  Created by Emmanuel Texier on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "NewTweetViewControllerDelegate.h"

@protocol ProfileImageTapDelegate;


@interface TweetCell : UITableViewCell
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, weak) id<NewTweetViewControllerDelegate> delegate;
@property (nonatomic, weak) id<ProfileImageTapDelegate> profileImageTapDelegate;
@end
