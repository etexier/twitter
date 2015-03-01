//
// Created by Emmanuel Texier on 2/24/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>

@interface User : MTLModel <MTLJSONSerializing>

#pragma mark - property
@property(nonatomic, copy, readonly) NSURL *profileImageUrl;
@property(nonatomic, copy, readonly) NSString *name;
@property(nonatomic, copy, readonly) NSString *screenName;
@property(nonatomic, copy, readonly) NSString *id;
@property(nonatomic, copy, readonly) NSNumber *followersCount;
@property(nonatomic, copy, readonly) NSNumber *followingCount;
@property(nonatomic, copy, readonly) NSNumber *tweetsCount;
#pragma mark - init

- (instancetype)initWithJson:(NSDictionary *)dictionaryValue;

@end