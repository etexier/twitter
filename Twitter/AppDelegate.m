//
//  AppDelegate.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "AppDelegate.h"
#import "TwitterClient.h"
#import "User.h"
#import "RevealViewController.h"
#import "TimelineViewController.h"
#import "ProfileViewController.h"
#import "MentionsViewController.h"
#import "MenuViewController.h"

//NSString *const kTwitterConsumerKey = @"5C74UkLNroHcsRsY2OnapFBx6";
//NSString *const kTwitterConsumerSecret = @"Lxl7qlBUdid7Za20UQu9PEAOzgjCs34wu7hUVoMFLLVMAycK6J";

NSString *const kTwitterConsumerKey = @"dqDJBbZXgTqQNm7j3c17vk4BP";
NSString *const kTwitterConsumerSecret = @"IvGcSlFq5GbG0Lbk1vMR577mHsd8bTH5yPhOL9rUubdLWG36Tt";

//NSString *const kTwitterConsumerKey = @"RGnU7YY7LJf2zV0zZ7J7Ikg1Z";
//NSString *const kTwitterConsumerSecret = @"x0we7O4KSFo1AAwppS2I43HD1v5Z0zDShoUu0spt6rJzhlT1rI";
@interface AppDelegate () <RevealControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure BDBTwitterClient
    NSLog(@"Creating client with consumer key");
    [TwitterClient createWithConsumerKey:kTwitterConsumerKey secret:kTwitterConsumerSecret];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // Timeline view controller
    TimelineViewController *timelineVc = [[TimelineViewController alloc] init];

    ProfileViewController *profileVc = [[ProfileViewController alloc] init];

    MentionsViewController *mentionsVc = [[MentionsViewController alloc] init];



    // menu view controller

    UINavigationController *mentionsNavigationController = [[UINavigationController alloc] initWithRootViewController:mentionsVc];
    mentionsNavigationController.navigationBar.translucent = NO;

    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileVc];
    profileNavigationController.navigationBar.translucent = NO;

    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineVc];
    timelineNavigationController.navigationBar.translucent = NO;

    NSArray *menuActions =
    @[
      @{@"name" : @"Home", @"controller" : timelineNavigationController},
      @{@"name" : @"Profile", @"controller" : profileNavigationController},
      @{@"name" : @"Mentions", @"controller" : mentionsNavigationController},
      ];

    MenuViewController *menuVc = [[MenuViewController alloc] initWithMenuActions:menuActions];
    UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:menuVc];
    menuNavigationController.navigationBar.translucent = NO;

    

    RevealViewController *revealVc = [[RevealViewController alloc] initWithFrontViewController:profileNavigationController
                                                                     andRearController:menuNavigationController];
    mentionsVc.revealControllerDelegate = revealVc;
    timelineVc.revealControllerDelegate = revealVc;
    profileVc.revealControllerDelegate = revealVc;
    menuVc.revealControllerDelegate = revealVc;

    self.window.rootViewController = revealVc;
    [self.window makeKeyAndVisible];

    return YES;
}


// called whenever somebody tries to open your application using your custom protocol
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([TwitterClient isAuthorizationCallbackURL:url]) {
        return [[TwitterClient sharedInstance] handleAuthorizationCallbackURL:url];
    }
    return NO;
}




@end
