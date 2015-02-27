//
//  MenuViewController.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/25/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RevealController.h"

@interface MenuViewController : UIViewController <RevealControllerDelegate>
- (instancetype) initWithMenuActions:(NSArray *) menuActions;

@property (weak, nonatomic) id<RevealControllerDelegate> revealControllerDelegate;


@end
