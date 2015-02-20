//
//  TwitterClient.h
//  Twitter
//
//  Created by Emmanuel Texier on 2/19/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+(TwitterClient *)sharedInstance;

@end
