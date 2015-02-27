//
//  MenuViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/25/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetsViewController.h"
#import "TweetsViewControllerDelegate.h"

@interface MenuViewController : UIViewController <TweetsViewControllerDelegate>

-(instancetype) initWithTweetsViewController:(TweetsViewController *)controller;

@end
