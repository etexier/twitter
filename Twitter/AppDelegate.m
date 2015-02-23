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

NSString *const kTwitterConsumerKey = @"5C74UkLNroHcsRsY2OnapFBx6";
NSString *const kTwitterConsumerSecret = @"Lxl7qlBUdid7Za20UQu9PEAOzgjCs34wu7hUVoMFLLVMAycK6J";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Configure BDBTwitterClient
    NSLog(@"Creating client with consumer key");
    [TwitterClient createWithConsumerKey:kTwitterConsumerKey secret:kTwitterConsumerSecret];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    TweetsViewController *vc = [[TweetsViewController alloc] init];
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
