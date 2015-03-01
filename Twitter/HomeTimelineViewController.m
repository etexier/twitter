//
// Created by Emmanuel Texier on 2/28/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "HomeTimelineViewController.h"
#import "TwitterClient.h"


@implementation HomeTimelineViewController

- (NSString *)timelinePath {
    return kTwitterClientHomeTimelinePath;
}

- (NSString *)timelineTitle {
    return @"Home";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *logInOutString = [[TwitterClient sharedInstance] isAuthorized] ? @"Sign Out" : @"Sign In";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logInOutString
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logInOut)];

    UIBarButtonItem *newTweetButton = [[UIBarButtonItem alloc] initWithTitle:@"New"/*initWithImage:[UIImage imageNamed:@"Twitter_logo_blue_32.png"]*/
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(onNewTweet)];
    self.navigationItem.rightBarButtonItem = newTweetButton;

}




@end