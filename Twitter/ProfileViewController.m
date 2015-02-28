//
//  ProfileViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/27/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "ProfileViewController.h"
#import "RevealViewController.h"
#import "TwitterClient.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

-(NSString *)timelinePath {
    return kTwitterClientProfileTimelinePath;
}


- (NSString *)timelineTitle {
    return @"Profile";
}
@end
