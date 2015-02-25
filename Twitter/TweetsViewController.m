//
//  TweetsViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/21/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "TweetsViewController.h"
#import "NewTweetViewController.h"
#import "TwitterClient.h"
#import "BBlock/UIKit+BBlock.h"
#import "User.h"
#import "TweetDetailsViewController.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "MBProgressHUD.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "Helper.h"

static NSString *const kTweetCell = @"TweetCell";

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, NewTweetViewControllerDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) NSMutableArray *tweets;
@property(nonatomic, strong) UIActivityIndicatorView *footerView;

@end

@implementation TweetsViewController

#pragma mark - NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialization

- (id)init {
    self = [super init];

    if (self) {
        self.tweets = [NSMutableArray array];

        // only on 7.0+
//        self.tableView.separatorInset = UIEdgeInsetsZero;

        // contextual log in/out right button based on login status
        // register notifications

        // Log out button if already logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidSignInNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          NSDictionary *userInfo = note.userInfo;
                                                          [Helper setCurrentUser:[[User alloc] initWithJson:userInfo]];
                                                          NSLog(@"Welcome user %@", [Helper currentUser].name);
                                                          [self loadTweets];
                                                          [self.navigationItem.leftBarButtonItem setTitle:@"Sign Out"];
                                                          [self.navigationItem.rightBarButtonItem setImage:nil];
                                                      }];


        // log in button if not logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidSignOutNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [Helper setCurrentUser:nil];
                                                          self.tweets = [NSMutableArray array];
                                                          [self.tableView reloadData];
                                                          [self.navigationItem.leftBarButtonItem setTitle:@"Sign In"];
                                                      }];


    }

    return self;
}

#pragma mark -

- (void)newTweetViewController:(NewTweetViewController *)controller sentTweet:(Tweet *)tweet {
    [self.tweets insertObject:tweet atIndex:0];
}


#pragma mark - ui view controller methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Tweets";

    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;

    // cell auto dim.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.tableView.separatorColor = [UIColor lightGrayColor];

    self.tableView.delegate = self;


    // refresh control reloads tweets on swipe down
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

    [self.refreshControl addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

    // cell registration
    [self.tableView registerNib:[UINib nibWithNibName:kTweetCell bundle:nil] forCellReuseIdentifier:kTweetCell];


    NSString *logInOutString = [[TwitterClient sharedInstance] isAuthorized] ? @"Sign Out" : @"Sign In";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:logInOutString
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(logInOut)];

    UIBarButtonItem *newTweetButton = [[UIBarButtonItem alloc] initWithTitle:@"New"/*initWithImage:[UIImage imageNamed:@"Twitter_logo_blue_32.png"]*/
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(onNewTweet)];
    self.navigationItem.rightBarButtonItem = newTweetButton;


    [self.tableView  addInfiniteScrollingWithActionHandler:^{
        // call [tableView.pullToRefreshView stopAnimating] when done
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [self loadTweetsPriorToMaxId:((Tweet *)[self.tweets lastObject]).id andAfterMinId:nil withProgress:YES];

    }];
    [self loadTweets];




    // Do any additional setup after loading the view from its nib.
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - table view delegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailsViewController *detailsVc = [[TweetDetailsViewController alloc] initWithTweet:self.tweets[(NSUInteger) indexPath.row]];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [self.navigationController pushViewController:detailsVc animated:YES];

}

#pragma mark - data source method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = (TweetCell *) [tableView dequeueReusableCellWithIdentifier:kTweetCell forIndexPath:indexPath];
    cell.tweet = self.tweets[(NSUInteger) indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark Authorization

- (void)logInOut {
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to sign out?"
                                cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Sign Out"
                                 otherButtonTitle:nil
                                  completionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet) {
                                      if (buttonIndex == actionSheet.destructiveButtonIndex) {
                                          [[TwitterClient sharedInstance] deAuthorize];
                                      }
                                  }]
                    showInView:self.view];
        });
    } else {
        [[TwitterClient sharedInstance] authorize];
    }
}

#pragma mark - button action

- (void)onNewTweet {
    if (![[TwitterClient sharedInstance] isAuthorized]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"You must sign in to tweet"
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:nil] show];
        return;
    }
    NewTweetViewController *vc = [[NewTweetViewController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - load data

- (void)loadTweets {
    [self loadTweets:YES];
}

- (void)loadTweets:(BOOL)withProgress {
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *minId = nil;
    if (self.tweets && self.tweets.count > 0) {
        minId = ((Tweet *) self.tweets[0]).id;
    }
    [self loadTweetsPriorToMaxId:nil andAfterMinId:minId withProgress:withProgress];
}



- (void)loadTweetsPriorToMaxId:(NSString *)maxId andAfterMinId:(NSString *)minId withProgress:(BOOL) withProgress{

    // show spinner while searching
    if (withProgress) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }

    if (![[TwitterClient sharedInstance] isAuthorized]) {
        dispatch_async(dispatch_get_main_queue(), ^{

            // end spinner
            if (withProgress) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            [[[UIAlertView alloc] initWithTitle:@"Not Signed In"
                                        message:@"You have to sign in first!"
                              cancelButtonTitle:@"Cancel"
                               otherButtonTitle:@"Sign In"
                                completionBlock:^(NSInteger buttonIndex, UIAlertView *alertView) {
                                    if (buttonIndex == alertView.cancelButtonIndex + 1) {
                                        [[TwitterClient sharedInstance] authorize];
                                    }
                                }]
                    show];
        });

        [self.refreshControl endRefreshing];

        return;
    }

    if (!self.refreshControl.isRefreshing) {
        [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y - self.refreshControl.frame.size.height)
                                animated:NO];
        [self.refreshControl beginRefreshing];
    }

    [[TwitterClient sharedInstance] loadTimelineOlderThanId:maxId
                                             andNewerThanId:minId
                                                 completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            [TwitterClient parseTweetsFromListResponse:tweets completion:^(NSMutableArray *parsedTweets, NSError *error1) {
                if (!error1) {
                    if (maxId) { // add at tail
                        [self.tweets addObjectsFromArray:parsedTweets];
                    } else if (minId) { // add at beginning
                        self.tweets = [[parsedTweets arrayByAddingObjectsFromArray:self.tweets] mutableCopy];
                    } else {
                        self.tweets = parsedTweets;
                    }
                } else {
                    NSLog(@"couldn't parse tweets");
                    return;
                }
            }];

        }
        // on UI thread
        dispatch_async(dispatch_get_main_queue(), ^{
            // end spinner
            if (withProgress) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            if (error) {
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:error.localizedDescription
                                           delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            }
            [self.tableView reloadData];
        });

        [self.refreshControl endRefreshing];
    }];
}

@end
