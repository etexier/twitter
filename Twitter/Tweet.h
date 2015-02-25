@import Foundation;

#import <Mantle/MTLModel.h>
#import "User.h"


@interface Tweet : MTLModel

#pragma mark - properties

@property(nonatomic, readonly) NSString *id;
@property(nonatomic, copy, readonly) NSString *text;
@property(nonatomic, copy, readonly) NSDate *createdAt;
@property(nonatomic, assign) NSUInteger retweetCount;
@property(nonatomic, assign) NSUInteger favoriteCount;
@property(nonatomic, assign) BOOL favorited;
@property(nonatomic, assign) BOOL retweeted;
@property(nonatomic, readonly) User *user;

#pragma mark - init

- (instancetype)initWithJson:(NSDictionary *)dictionary;

@end
