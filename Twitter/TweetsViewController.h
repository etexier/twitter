//
//  TweetsViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@interface TweetsViewController : UIViewController

- (void)loadTweets;

- (void)loadTweets:(BOOL)withProgress;

@end
