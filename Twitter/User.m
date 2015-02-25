//
// Created by Emmanuel Texier on 2/24/15.
// Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Mantle/MTLJSONAdapter.h>
#import <Mantle/MTLValueTransformer.h>
#import "User.h"

@interface User ()

@end

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
            @"id" : @"id_str",
            @"name" : @"name",
            @"screenName" : @"screen_name",
            @"profileImageUrl" : @"profile_image_url"
    };
}

- (instancetype)initWithJson:(NSDictionary *)dictionary {
    NSLog(@"Dictionary is %@", dictionary);
    NSMutableDictionary *filteredDictionary = [NSMutableDictionary dictionary];
    NSArray *allKeys = [[User JSONKeyPathsByPropertyKey] allValues];
    for (NSString *key in allKeys) {
        filteredDictionary[key] = dictionary[key];
    }
    NSLog(@"User filteredDictionary : \n%@", filteredDictionary);
    self = [MTLJSONAdapter modelOfClass:User.class fromJSONDictionary:filteredDictionary error:nil];
    return self;
}

+ (NSValueTransformer *)profileImageUrlJSONTransformer {
//    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];

    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        NSString *userImageURLString = [str stringByReplacingOccurrencesOfString:@"_normal"
                                                                      withString:@"_bigger"];
        return [NSURL URLWithString:userImageURLString];
    } reverseBlock:^(NSURL *url) {
        return [url absoluteString];
    }];
}

@end