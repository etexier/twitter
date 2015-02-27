//
//  AppDelegate.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "AppDelegate.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "MenuViewController.h"
#import "User.h"
#import "ViewController.h"

//NSString *const kTwitterConsumerKey = @"5C74UkLNroHcsRsY2OnapFBx6";
//NSString *const kTwitterConsumerSecret = @"Lxl7qlBUdid7Za20UQu9PEAOzgjCs34wu7hUVoMFLLVMAycK6J";

NSString *const kTwitterConsumerKey = @"dqDJBbZXgTqQNm7j3c17vk4BP";
NSString *const kTwitterConsumerSecret = @"IvGcSlFq5GbG0Lbk1vMR577mHsd8bTH5yPhOL9rUubdLWG36Tt";

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
    TweetsViewController *tvc = [[TweetsViewController alloc] init];
    //MenuViewController *mvc = [[MenuViewController alloc] init];
    ViewController *vc = [[ViewController alloc] initWithTweetsViewController:tvc];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    nvc.navigationBar.translucent = NO; // so table view first row is not hidden behind it

    self.window.rootViewController = nvc;
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
