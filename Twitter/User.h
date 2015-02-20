//
//  User.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenname;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *tagline;

-(id) initWithDictionary:(NSDictionary *) dictionary;

@end
