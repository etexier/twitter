//
//  UserHeaderView.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/28/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "UserHeaderView.h"

@implementation UserHeaderView


+ (instancetype)userHeaderView {
    UserHeaderView *userHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"UserHeaderView" owner:nil options:nil] lastObject];
    return userHeaderView;
}
@end
