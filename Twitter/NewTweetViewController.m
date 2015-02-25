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
#import "NewTweetViewControllerDelegate.h"
#import "Helper.h"
#import "NewTweetViewControllerDelegate.h"

#pragma mark -

@interface NewTweetViewController () <UITextViewDelegate>
@property(weak, nonatomic) IBOutlet UITextView *tweetTextView;
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UILabel *tweetLabel;

@property(strong, nonatomic) NSURL *imageURL;

@property(nonatomic, strong) NSString *replyToScreenName;
@property(nonatomic, strong) NSString *replyToTweetId;
@property(weak, nonatomic) IBOutlet UILabel *limitLabel;


@end

#pragma mark -

@implementation NewTweetViewController

#pragma mark - init

- (id)initWithDelegate:(id) delegate{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
    
}


- (id)initAsReplyTo:(NSString *)replyToScreenName forTweetId:(NSString *)replyToTweetId delegate:(id) delegate {
    self = [self initWithDelegate:delegate];
    if (self) {
        self.replyToScreenName = replyToScreenName;
        self.replyToTweetId = replyToTweetId;
    }
    return self;

}

#pragma mark - text view delegate methods

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    if (self.tweetTextView.textColor == [UIColor lightGrayColor]) {
        self.tweetTextView.text = @"";
        self.tweetTextView.textColor = [UIColor blackColor];
    }

    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    int left = 140 - [self.tweetTextView.text length];
    self.limitLabel.text = [NSString stringWithFormat:@"%i", left];
    if (left >= 0) {
        self.limitLabel.textColor = [UIColor lightGrayColor];
    } else {
        self.limitLabel.textColor = [UIColor redColor];

    }
}

#pragma mark - ui view controller method


-(void) viewDidAppear:(BOOL) animated {
    [super viewDidAppear:animated];
    [self.tweetTextView becomeFirstResponder];
}
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


    // do this because the navigation controller is pushing down the text view, we want to start editing at the top line
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.tweetTextView.contentInset = UIEdgeInsetsMake(-7.0, 0.0, 0, 0.0);

    // round image
    [self.imageView setImageWithURL:[Helper currentUser].profileImageUrl];
    self.tweetLabel.text = [Helper currentUser].screenName;
    self.imageView.layer.cornerRadius = 5 ; //self.imageView.frame.size.width / 2.0f; // completely round
    self.imageView.clipsToBounds = YES;
    self.tweetTextView.delegate = self;
    [self.tweetTextView setText:@"What's happening..."];
    [self.tweetTextView setTextColor:[UIColor lightGrayColor]];




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
    [[self navigationController] popViewControllerAnimated:YES];
}


#pragma mark - private

- (void)sendTweetText:(NSString *)text {

    // reply message
    if (self.replyToScreenName) {
        [[TwitterClient sharedInstance] replyTo:self.replyToTweetId withTweetText:text completion:^(NSDictionary *response, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            [self.delegate newTweetViewController:self sentTweet:[[Tweet alloc] initFromCurrentUserTweetText:text]];
            NSLog(@"Reply tweet sent");
            // Must dispatch on UI thread for UI interaction
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        }];
        return;
    }

    // update status only
    [[TwitterClient sharedInstance] updateStatus:text completion:^(NSDictionary *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        NSLog(@"Tweet sent");
        [self.delegate newTweetViewController:self sentTweet:[[Tweet alloc] initFromCurrentUserTweetText:text]];
        // Must dispatch on UI thread for UI interaction
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self navigationController] popViewControllerAnimated:YES];
        });
    }];


}

@end
