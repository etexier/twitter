//
//  ProfileViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/27/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RevealControllerDelegate;

@interface ProfileViewController : UIViewController

@property(weak, nonatomic) id<RevealControllerDelegate> revealControllerDelegate;

@end
