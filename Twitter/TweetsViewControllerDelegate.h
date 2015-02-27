//
//  TweetsViewControllerDelegate.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/26/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TweetsViewController;

@protocol TweetsViewControllerDelegate <NSObject>

- (void)onPanGesture:(UIPanGestureRecognizer *)sender onController:(TweetsViewController *) controller ;

@end
