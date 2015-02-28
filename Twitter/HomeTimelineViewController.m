//
// Created by Emmanuel Texier on 2/28/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "HomeTimelineViewController.h"
#import "TwitterClient.h"


@implementation HomeTimelineViewController

- (NSString *) timelinePath {
    return kTwitterClientHomeTimelinePath;
}

- (NSString *)timelineTitle {
    return @"Home";
}




@end