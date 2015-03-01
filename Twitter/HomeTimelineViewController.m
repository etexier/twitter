//
// Created by Emmanuel Texier on 2/28/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <BBlock/UIActionSheet+BBlock.h>
#import "HomeTimelineViewController.h"
#import "TwitterClient.h"
#import "NewTweetViewController.h"


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

#pragma mark - button action

- (void)onNewTweet {
    if (![[TwitterClient sharedInstance] isAuthorized]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"You must sign in to tweet"
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
        return;
    }
    NewTweetViewController *vc = [[NewTweetViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)logInOut {
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to sign out?"
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Sign Out"
                                 otherButtonTitle:nil
                                  completionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet) {
                                      if (buttonIndex == actionSheet.destructiveButtonIndex) {
                                          [[TwitterClient sharedInstance] deAuthorize];
                                          [self.revealControllerDelegate transitionToLoginController];

                                      }
                                  }]
             showInView:self.view];
        });
    } else {
        [[TwitterClient sharedInstance] authorize];
    }
}






@end