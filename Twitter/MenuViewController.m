//
//  MenuViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/25/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "MenuViewController.h"
#import "TweetsViewController.h"

@interface MenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *menuActions;

typedef NS_ENUM(NSInteger, MenuActionType) {
    MenuActionTypeHome = 0,
    MenuActionTypeAccount,
    MenuActionTypeSettings,
};


@end

@implementation MenuViewController

#pragma mark - init
#pragma mark - view controllers

- (instancetype) init {
    self = [super init];
    if (self) {
        self.menuActions = @[@"Home", @"Account", @"Settings"];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

#pragma mark - table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuActions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuActionCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuActionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = self.menuActions[indexPath.row];
    cell.imageView.image = nil;
    return cell;

}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case MenuActionTypeHome: {
            NSLog(@"Home selected");
            TweetsViewController *vc = [[TweetsViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case MenuActionTypeAccount:
            NSLog(@"Account selected. Not supported yet");
            break;
        case MenuActionTypeSettings:
            NSLog(@"Settings selected. Not supported yet");
            break;
        default:
            NSAssert(NO, @"Unsupported selection");
    }
    
}





@end
