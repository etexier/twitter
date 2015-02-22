//
//  TweetCell.h
//  Yelp
//
//  Created by Emmanuel Texier on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Business.h"

@interface TweetCell : UITableViewCell
@property (nonatomic, strong) Business *business;
@end
