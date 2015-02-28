//
//  TimelineViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@protocol RevealControllerDelegate;

@interface TimelineViewController : UIViewController

@property(weak, nonatomic) id<RevealControllerDelegate> revealControllerDelegate;

- (void)loadTweets;

- (void)loadTweets:(BOOL)withProgress;

- (NSString *)actualMinId;
@end
