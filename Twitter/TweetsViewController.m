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
#import "TweetDetailsViewController.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "MBProgressHUD.h"
#import "Helper.h"

static NSString *const kTweetCell = @"TweetCell";

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic, strong) NSArray *tweets;
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
        self.tweets = [NSArray array];

        // only on 7.0+
//        self.tableView.separatorInset = UIEdgeInsetsZero;

        // contextual log in/out right button based on login status
        // register notifications

        // Log out button if already logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidSignInNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self loadTweets];
                                                          [self.navigationItem.leftBarButtonItem setTitle:@"Sign Out"];
                                                          [self.navigationItem.rightBarButtonItem setImage:nil];
                                                      }];


        // log in button if not logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidSignOutNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          self.tweets = [NSArray array];
                                                          [self.tableView reloadData];
                                                          [self.navigationItem.leftBarButtonItem setTitle:@"Sign In"];
                                                      }];


    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Tweets";
    self.willReloadTweets = YES;

    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;

    // cell auto dim.
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.delegate = self;


    // refresh control reloads tweets on swipe down
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadTweets) forControlEvents:UIControlEventValueChanged];
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


    self.tableView.separatorColor = [UIColor clearColor];



    // Do any additional setup after loading the view from its nib.
}


- (void)viewDidAppear:(BOOL)animated {
    // do not reload here as this will you will visually see the cell's height being re-adjusted -> use viewWillAppear
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do we want to reload the data everytime?
    if (!self.willReloadTweets) {
        self.willReloadTweets = YES;
        [self.tableView reloadData];
        return;
    }
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        [self loadTweets];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailsViewController *detailsVc = [[TweetDetailsViewController alloc] initWithTweet:self.tweets[(NSUInteger) indexPath.row]];

    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    self.willReloadTweets = NO; // do not reload the tweet.
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
    // show the separator line
    if (indexPath.row == self.tweets.count - 1) {
        cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
        if ([[TwitterClient sharedInstance] isAuthorized]) {
            [self footerViewStart];
            [[TwitterClient sharedInstance] loadTimelineOlderThanId:cell.tweet.id completion:^(NSArray *rawTweets, NSError *error) {
                if (!error) {
                    [TwitterClient parseTweetsFromListResponse:rawTweets completion:^(NSArray *parsedTweets, NSError *error1) {
                        if (!error1) {
                            NSMutableArray *newTweets = [self.tweets mutableCopy];
                            [newTweets addObjectsFromArray:parsedTweets];
                            self.tweets = newTweets;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self footerViewStop];
                                [self loadTweets:NO];
                            });
                        }
                    }];
                }
            }];
        }
    }
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static TweetCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:kTweetCell];
    });

    sizingCell.tweet = self.tweets[(NSUInteger) indexPath.row];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
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
    NewTweetViewController *vc = [[NewTweetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - load data
- (void)loadTweets {
    [self loadTweets:YES];
}

- (void)loadTweets:(BOOL)withProgress {
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

    [[TwitterClient sharedInstance] loadTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            [TwitterClient parseTweetsFromListResponse:tweets completion:^(NSArray *parsedTweets, NSError *error1) {
                if (!error1) {
                    self.tweets = parsedTweets;
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

#pragma mark - other private methods

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];

    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}


// not used
- (void)reloadSingleTweetById:(NSString *)id {
    [[TwitterClient sharedInstance] showTweet:id completion:^(NSDictionary *dictionary, NSError *error) {
        if (error) {
            NSLog(@"Error showing tweet: %@", error.localizedDescription);
            // quietly forget it
        } else {
            int found = [Helper findTweetIndexWithId:id fromTweets:self.tweets];
            if (found == -1) {
                NSLog(@"Error: couldn't find tweet with id %d", found);
            }

            // update tweet array.
            NSMutableArray *newTweets = [self.tweets mutableCopy];
            newTweets[(NSUInteger) found] = [[Tweet alloc] initWithDictionary:dictionary];
            self.tweets = newTweets;
            [self.tableView reloadData];
        }
    }];

}

-(void) footerViewStart {

    // TODO: implement auto-layout
    
//    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.footerView = loadingView;
//    [self.footerView startAnimating];
//    self.footerView.center = tableFooterView.center;
//    [tableFooterView addSubview:self.footerView];
//    self.tableView.tableFooterView = tableFooterView;
    
}

-(void) footerViewStop {
//    [self.footerView stopAnimating];
}

@end
