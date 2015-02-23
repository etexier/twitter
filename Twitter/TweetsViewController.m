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

static NSString *const kTweetCell = @"TweetCell";
@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate>
@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, strong) UIRefreshControl *refreshControl;
@property(nonatomic) NSMutableDictionary *offScreenCells;
@property(nonatomic, strong) NSArray *tweets;


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
        self.offScreenCells = [NSMutableDictionary dictionary];
        self.tweets = [NSArray array];

        // only on 7.0+
//        self.tableView.separatorInset = UIEdgeInsetsZero;

        // contextual log in/out right button based on login status
        // register notifications

        // Log out button if already logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidLogInNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          [self loadTweets];
                                                          [self.navigationItem.leftBarButtonItem setTitle:@"Sign Out"];
                                                      }];


        // log in button if not logged in
        [[NSNotificationCenter defaultCenter] addObserverForName:TwitterClientDidLogOutNotification
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
    // do not reload here as this will you will visually see the cell's height being re-adjusted -> use viewWillAppear
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIBarButtonItem *newTweetButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(onNewTweet)];
    self.navigationItem.rightBarButtonItem = newTweetButton;
    
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
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TweetDetailsViewController * detailsVc = [[TweetDetailsViewController alloc] initWithTweet:self.tweets[(NSUInteger) indexPath.row]];

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
    TweetCell * cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:kTweetCell forIndexPath:indexPath];
    cell.tweet = self.tweets[(NSUInteger) indexPath.row];
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static TweetCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:kTweetCell];
    });
    
    sizingCell.tweet = self.tweets[indexPath.row];
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
    NewTweetViewController *vc = [[NewTweetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - load data

- (void)loadTweets {
    if (![[TwitterClient sharedInstance] isAuthorized]) {
        dispatch_async(dispatch_get_main_queue(), ^{
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

            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Error"
                                            message:error.localizedDescription
                                           delegate:self
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles:nil] show];
            });
        } else {
            self.tweets = tweets;

            [self.tableView reloadData];
        }

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




@end
