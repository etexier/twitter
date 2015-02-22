
@import Foundation;

#pragma mark -
@interface Tweet : NSObject

@property (nonatomic, copy, readonly) NSDate *createdAt;
@property (nonatomic, copy, readonly) NSURL *userImageURL;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *userScreenName;
@property (nonatomic, copy, readonly) NSString *retweetInfo;
@property (nonatomic, copy, readonly) NSString *tweetText;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
