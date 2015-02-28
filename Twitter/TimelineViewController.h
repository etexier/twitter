//
//  TimelineViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RevealViewController.h"

@class User;
@protocol RevealViewControllerDelegate;

@interface TimelineViewController : UIViewController

@property(weak, nonatomic) NSString *screenName;


@property(weak, nonatomic) id <RevealViewControllerDelegate> revealControllerDelegate;

- (void)loadTweets;

- (void)loadTweets:(BOOL)withProgress;

- (NSString *)actualMinId;

- (NSString *)timelinePath;

- (NSString *)timelineTitle;


@end
