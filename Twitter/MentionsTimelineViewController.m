//
//  MentionsTimelineViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/27/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "MentionsTimelineViewController.h"
#import "RevealViewController.h"
#import "TwitterClient.h"

@interface MentionsTimelineViewController ()

@end

@implementation MentionsTimelineViewController

- (NSString *)timelineTitle {
    return @"Mentions";
}


- (NSString *)timelinePath {
    return kTwitterClientMentionsTimelinePath;
}


@end
