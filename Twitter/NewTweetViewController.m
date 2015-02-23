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

@interface NewTweetViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@end

@implementation NewTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"New Tweet";
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onCancelTweet)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(onSendTweet)];
    
    self.tweetTextView.backgroundColor = [UIColor darkGrayColor];
    self.tweetTextView.contentInset = UIEdgeInsetsMake(-7.0,0.0,0,0.0);
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - actions
- (void)onSendTweet {
    [self sendTweetText:self.tweetTextView.text];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) onCancelTweet {
    TweetsViewController *vc = [self backViewController];
    vc.willReloadTweets = NO;
    [[self navigationController] popViewControllerAnimated:YES];
    
}

#pragma mark - private
- (void) sendTweetText:(NSString *)text {
    
    [[TwitterClient sharedInstance] updateStatus:text completion:^(NSArray *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:error.localizedDescription
                                           delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            });
        } else {
            NSLog(@"Test tweet sent");
        }
        
    }];

}

- (TweetsViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    if (numberOfViewControllers < 2) {
        return nil;
    } else {
        NSUInteger index = (NSUInteger) (numberOfViewControllers - 2);
        return (TweetsViewController *) self.navigationController.viewControllers[index];
    }
}
@end
