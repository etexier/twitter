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
#import "Helper.h"
#import "UserHeaderView.h"
#import "UIImageView+AFNetworking.h"


@interface ProfileViewController ()

@end

@implementation ProfileViewController

-(void)viewDidLoad {
    [super viewDidLoad];

    if (!self.user) {
        self.user = [Helper currentUser];
    }
    UserHeaderView *headerView = [UserHeaderView userHeaderView];

    headerView.FollowersNumberLabel.text = [self.user.followersCount stringValue];
    headerView.followingNumberLabel.text = [self.user.followingCount stringValue];
    headerView.tweetsNumberLabel.text = [self.user.tweetsCount stringValue];
    headerView.userNameLabel.text = self.user.name;
    headerView.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName ];
    [headerView.imageView setImageWithURL:self.user.profileImageUrl];
    headerView.imageView.layer.cornerRadius = 5; // self.userImageView.frame.size.width / 2.0f;
    headerView.imageView.clipsToBounds = YES;

    [self.view addSubview:headerView];
    self.tableView.tableHeaderView = headerView;


}
-(NSString *)timelinePath {
    return kTwitterClientProfileTimelinePath;
}


- (NSString *)timelineTitle {
    return @"Profile"; //self.user ? self.user.name : [Helper currentUser].name;
}
@end
