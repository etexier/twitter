//
//  TweetCell.h
//
//  Created by Emmanuel Texier on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
#import "NewTweetViewControllerDelegate.h"

@interface TweetCell : UITableViewCell <NewTweetViewControllerDelegate>
@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, weak) id<NewTweetViewControllerDelegate> delegate;
@end
