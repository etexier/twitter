//
//  TweetDetailsViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "Tweet.h"

@interface TweetDetailsViewController ()

@end

@implementation TweetDetailsViewController
- (id)initWithTweet:(Tweet *)tweet {
    self = [super init];
    if (self) {
        self.tweet = tweet;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tweet";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
