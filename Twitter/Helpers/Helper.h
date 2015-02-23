//
// Created by Emmanuel Texier on 2/21/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Helper : NSObject
+ (void) fadeInImage:(UIImageView *)imageView url:(NSURL *) url;


+ (NSString *)calculateTimeAgoTillDate:(NSDate *)date;
@end
