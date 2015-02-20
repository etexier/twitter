//
//  AppDelegate.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TwitterClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginViewController *vc = [[LoginViewController alloc] init];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// called whenever somebody tries to open your application using your custom protocol
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [[[TwitterClient sharedInstance] fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        NSLog(@"got the access token!");
        
        [[TwitterClient sharedInstance].requestSerializer saveAccessToken:accessToken];
        
        [[TwitterClient sharedInstance] GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"current user : %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed getting current user");
        }];
        
        [[TwitterClient sharedInstance] GET:@"1.1/statuses/home_timeline.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"tweets: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Failed to get tweets!");
        }];
    } failure:^(NSError *error) {
        NSLog(@"Failed to get the access token!");
    }];
    return YES;
}

@end
