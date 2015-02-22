//
//  TweetCell.m
//  Yelp
//
//  Created by Emmanuel Texier on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"

@interface TweetCell ()

@property(weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property(weak, nonatomic) IBOutlet UILabel *addressLabel;
@property(weak, nonatomic) IBOutlet UILabel *numReviewsLabel;
@property(weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property(weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    self.thumbImageView.layer.cornerRadius = 3;
    self.thumbImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(Business *)business {
    _business = business;
    [self.thumbImageView setImageWithURL:[NSURL URLWithString:self.business.imageUrl]];
    self.nameLabel.text = self.business.name;
    self.addressLabel.text = self.business.address;
    self.numReviewsLabel.text = [NSString stringWithFormat:@"%ld reviews", (long) self.business.numReviews];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", self.business.distance];
    [self.ratingImageView setImageWithURL:[NSURL URLWithString:self.business.ratingImageUrl]];
    self.categoryLabel.text = self.business.categories;
}

-(void) layoutSubviews {
    [super layoutSubviews];
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    
}

@end
