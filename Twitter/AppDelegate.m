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
#import "MentionsTimelineViewController.h"
#import "MenuViewController.h"
#import "HomeTimelineViewController.h"
#import "Helper.h"
#import "LoginViewController.h"

NSString *const kTwitterConsumerKey = @"5C74UkLNroHcsRsY2OnapFBx6";
NSString *const kTwitterConsumerSecret = @"Lxl7qlBUdid7Za20UQu9PEAOzgjCs34wu7hUVoMFLLVMAycK6J";

//NSString *const kTwitterConsumerKey = @"dqDJBbZXgTqQNm7j3c17vk4BP";
//NSString *const kTwitterConsumerSecret = @"IvGcSlFq5GbG0Lbk1vMR577mHsd8bTH5yPhOL9rUubdLWG36Tt";

//NSString *const kTwitterConsumerKey = @"RGnU7YY7LJf2zV0zZ7J7Ikg1Z";
//NSString *const kTwitterConsumerSecret = @"x0we7O4KSFo1AAwppS2I43HD1v5Z0zDShoUu0spt6rJzhlT1rI";
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure BDBTwitterClient
    NSLog(@"Creating client with consumer key");
    [TwitterClient createWithConsumerKey:kTwitterConsumerKey secret:kTwitterConsumerSecret];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    // Timeline view controller
    HomeTimelineViewController *homeVc =  [[HomeTimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
    homeVc.slideable = YES;


    ProfileViewController *profileVc = [[ProfileViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
    profileVc.slideable = YES;

    MentionsTimelineViewController *mentionsVc = [[MentionsTimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
    mentionsVc.slideable = YES;



    // menu view controller

    UINavigationController *mentionsNavigationController = [[UINavigationController alloc] initWithRootViewController:mentionsVc];
    [Helper initLayoutForController:mentionsNavigationController];

    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileVc];
    [Helper initLayoutForController:profileNavigationController];

    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:homeVc];
    [Helper initLayoutForController:homeNavigationController];


    NSMutableArray *actions = [NSMutableArray array];
    actions[MenuActionHome] = @{@"name" : @"Home", @"controller" : homeNavigationController};
    actions[MenuActionMentions] =  @{@"name" : @"Mentions", @"controller" : mentionsNavigationController};
    actions[MenuActionProfile] = @{@"name" : @"Profile", @"controller" : profileNavigationController};

    NSArray *menuActions = [NSArray arrayWithArray:actions];

    MenuViewController *menuVc = [[MenuViewController alloc] initWithMenuActions:menuActions];
    UINavigationController *menuNavigationController = [[UINavigationController alloc] initWithRootViewController:menuVc];
    [Helper initLayoutForController:menuNavigationController];


    LoginViewController *loginVc = [[LoginViewController alloc] initWithFrontViewController:homeNavigationController];


    RevealViewController *revealVc = [[RevealViewController alloc] initWithFrontViewController:loginVc
                                                                             andRearController:menuNavigationController
                                                                                   menuActions:menuActions];


    mentionsVc.revealControllerDelegate = revealVc;
    homeVc.revealControllerDelegate = revealVc;
    profileVc.revealControllerDelegate = revealVc;
    menuVc.revealControllerDelegate = revealVc;
    loginVc.revealControllerDelegate = revealVc;

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
