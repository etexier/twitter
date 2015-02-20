//
//  LoginViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"

@interface LoginViewController ()

- (IBAction)onLogin:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken]; // clear first
    [[TwitterClient sharedInstance] fetchRequestTokenWithPath:@"oauth/request_token"
                                                       method:@"GET"
                                                  callbackURL:[NSURL URLWithString:@"etexiertwitter://oauth"]
                                                        scope:nil
      success:^(BDBOAuth1Credential *requestToken) {
          
          NSLog(@"Got request token!");
          NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
          
          // open url: this is the main mechanism used by iOS app to communicate with each other
          [[UIApplication sharedApplication] openURL:authURL];
      } failure:^(NSError *error) {
          NSLog(@"Failed to get request token!");
      }];
    
}
@end
