//
//  NewTweetViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "NewTweetViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Helper.h"

#pragma mark -

@interface NewTweetViewController ()
@property(weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UILabel *tweetLabel;

@property(strong, nonatomic) NSURL *imageURL;

@property(nonatomic, strong) NSString *replyToScreenName;
@property(nonatomic, strong) NSString *replyToTweetId;


@end

#pragma mark -

@implementation NewTweetViewController

#pragma mark - init

- (id)initAsReplyTo:(NSString *)replyToScreenName forTweetId:(NSString *)replyToTweetId {
    self = [super init];
    if (self) {
        self.replyToScreenName = replyToScreenName;
        self.replyToTweetId = replyToTweetId;
    }
    return self;

}

#pragma mark - ui view controller method


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.replyToScreenName) {
        self.title = [NSString stringWithFormat:@"To @%@", self.replyToScreenName];
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@ ", _replyToScreenName];
    } else {
        self.title = @"New Tweet";
    }
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onCancelTweet)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(onSendTweet)];

    self.tweetTextView.backgroundColor = [UIColor whiteColor];
    // do this because the navigation controller is pushing down the text view, we want to start editing at the top line
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.tweetTextView.contentInset = UIEdgeInsetsMake(-7.0, 0.0, 0, 0.0);

    //To make the border look very close to a UITextField
    [self.tweetTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.tweetTextView.layer setBorderWidth:2.0];

    //The rounded corner part, where you specify your view's corner radius:
    self.tweetTextView.layer.cornerRadius = 7;
    self.tweetTextView.clipsToBounds = YES;

    // round image
    if (!self.imageURL) {
        [[TwitterClient sharedInstance] showSignedInUserInfoWithCompletion:^(NSDictionary *dictionary, NSError *error) {
            NSLog(@"Getting user info for logged in user ...");

            if (error) {
                // quietly error out
            } else {
                self.imageURL = [NSURL URLWithString:dictionary[@"profile_image_url"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.imageView setImageWithURL:self.imageURL];
                    NSString *screenName = dictionary[@"screen_name"];
                    self.tweetLabel.text = [NSString stringWithFormat:@"@%@ tweets:", screenName];
                });
            }
        }];
    } else {
        [self.imageView setImageWithURL:self.imageURL];
    }
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2.0f;
    self.imageView.clipsToBounds = YES;


}

#pragma mark - actions

- (void)onSendTweet {
    NSUInteger len = [self.tweetTextView.text length];
    if (len == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please enter some text first."
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    } else if (len > 140) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Your tweet exceeds 140 characters"
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
    } else {
        [self sendTweetText:self.tweetTextView.text];
    }
}

- (void)onCancelTweet {
    [self navigateBackAndReload:NO];
}


#pragma mark - private

- (void)navigateBackAndReload:(BOOL)reload {
    TweetsViewController *vc = [Helper backViewController:self.navigationController];
    vc.willReloadTweets = reload; // no need to reload tweet if no tweet is sent. Let the user pull down the table
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)sendTweetText:(NSString *)text {
    if (self.replyToScreenName) {
        [[TwitterClient sharedInstance] replyTo:self.replyToTweetId withTweetText:text completion:^(NSDictionary *response, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            NSLog(@"Reply tweet sent");
            // Must dispatch on UI thread for UI interaction
            dispatch_async(dispatch_get_main_queue(), ^{
                [self navigateBackAndReload:YES];
            });
        }];
        return;
    }
    [[TwitterClient sharedInstance] updateStatus:text completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        NSLog(@"Tweet sent");
        // Must dispatch on UI thread for UI interaction
        dispatch_async(dispatch_get_main_queue(), ^{
            [self navigateBackAndReload:YES];
        });
    }];


}

@end
