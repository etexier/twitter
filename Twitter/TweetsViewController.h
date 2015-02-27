//
//  TweetsViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetsViewControllerDelegate.h"

@class User;

@interface TweetsViewController : UIViewController

@property(weak, nonatomic) id<TweetsViewControllerDelegate> tweetViewControllerDelegate;

- (void)loadTweets;

- (void)loadTweets:(BOOL)withProgress;

- (NSString *)actualMinId;
@end
