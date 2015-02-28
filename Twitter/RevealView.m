//
// Created by Emmanuel Texier on 2/27/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "RevealView.h"
#import "RevealViewController.h"

@interface RevealView()
@property (nonatomic, weak) RevealViewController *revealController;
@end
@implementation RevealView


- (id)initWithFrame:(CGRect)frame controller:(RevealViewController *)controller {
    self = [super initWithFrame:frame];
    if ( self )
    {
        self.revealController = controller;

        CGRect bounds = self.bounds;

        // create a front view
        _frontView = [[UIView alloc] initWithFrame:bounds];
        _frontView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        // create a rear view
        _rearView = [[UIView alloc] initWithFrame:self.bounds];
        _rearView.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        // insert views in self
        [self addSubview:_frontView];
        [self insertSubview:_rearView belowSubview:_frontView];

    }
    return self;
}


@end