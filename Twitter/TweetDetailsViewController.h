//
//  TweetDetailsViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tweet;

@interface TweetDetailsViewController : UIViewController

@property (nonatomic, weak) Tweet *tweet;

-(id) initWithTweet:(Tweet *)tweet;

@end
