//
// Created by Emmanuel Texier on 2/27/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>

@class RevealViewController;

@interface RevealView : UIView

- (id)initWithFrame:(CGRect)frame controller:(RevealViewController *)controller;

@property (nonatomic, readonly) UIView *rearView;
@property (nonatomic, readonly) UIView *frontView;

@end