//
//  LoginViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/28/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "RevealViewController.h"
#import "Helper.h"

@interface LoginViewController ()
@property(weak, nonatomic) IBOutlet UIButton *signInButton;
@property(nonatomic, weak) UIViewController *frontViewController;

@end

@implementation LoginViewController
- (instancetype)initWithFrontViewController:(UIViewController *)frontViewController {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidSignInNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          NSDictionary *userInfo = note.userInfo;
                                                          [Helper setCurrentUser:[[User alloc] initWithJson:userInfo]];
                                                          NSLog(@"Welcome user %@", [Helper currentUser].name);
                                                          [self login];

                                                      }];

        self.frontViewController = frontViewController;
    }

    return self;
}


- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        self.signInButton.hidden = YES;
        self.signInButton.userInteractionEnabled = NO;

        [self login];
    } else {
        self.signInButton.hidden = NO;
        self.signInButton.userInteractionEnabled = YES;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)login {
    [self.revealControllerDelegate slideOverToController:self.frontViewController];

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
- (IBAction)onSignIn:(id)sender {
    [[TwitterClient sharedInstance] authorize];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
