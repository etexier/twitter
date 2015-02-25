//
//  NewTweetViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewTweetViewControllerDelegate;

@interface NewTweetViewController : UIViewController

@property (nonatomic, weak) id <NewTweetViewControllerDelegate> delegate;

- (instancetype)initWithDelegate:(id) delegate;

- (instancetype)initAsReplyTo:(NSString *)replyToScreenName forTweetId:(NSString *)replyToTweetId delegate:(id)delegate;
@end
