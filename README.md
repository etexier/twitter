## Twitter [(raw)](https://gist.githubusercontent.com/timothy1ee/b9b1860c8ecb4b0b1c18/raw/2adc3f63677d81644e00245cee891eee88907767/gistfile1.md)

This is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: `18h`

### Features

#### Required

- [X] User can sign in using OAuth login flow
- [X] User can view last 20 tweets from their home timeline
- [X] The current signed in user will be persisted across restarts
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [X] User can pull to refresh
- [X] User can compose a new tweet by tapping on a compose button.
- [ ] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [ ] User can retweet, favorite, and reply to the tweet directly from the timeline feed.

#### Optional

- [ ] When composing, you should have a countdown in the upper right for the tweet limit.
- [ ] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [ ] Retweeting and favoriting should increment the retweet and favorite count.
- [ ] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [ ] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [ ] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

### Walkthrough
![Demo](twitter-demo.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

Credits
---------
* [Twitter API](http://developer.rottentomatoes.com/docs/read/JSON)
* [BDOAuth1Manager](https://github.com/AFNetworking/AFNetworking)
* [MBProgressHUD](https://github.com/magnetsystems/rest2mobile)
* [BBlock/UIKit](https://github.com/magnetsystems/rest2mobile)
* Icons made by [Daniel Bruce](http://www.danielbruce.se), (Freepik)[http://www.freepik.com] from [Flaticon](http://www.flaticon.com is licensed by [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/)

### License

Licensed under the **[Apache License, Version 2.0] [license]** (the "License");
you may not use this software except in compliance with the License.
