//
//  MenuViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/25/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "MenuViewController.h"
#import "RevealController.h"



@interface MenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *menuActions;


@end

@implementation MenuViewController

#pragma mark - init



- (instancetype) initWithMenuActions:(NSArray *) menuActions{
    self = [super init];
    if (self) {
        self.menuActions = menuActions;
    }
    return self;
    
}

#pragma mark - view controllers

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
    cell.textLabel.text = self.menuActions[(NSUInteger) indexPath.row][@"name"];
    cell.imageView.image = nil;
    return cell;

}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@ selected", (NSString *) self.menuActions[(NSUInteger) indexPath.row][@"name"]);
    id value = self.menuActions[(NSUInteger) indexPath.row][@"controller"];
    if (value == [NSNull null]) {
        NSLog(@"Menu Action Not supported yet");
        return;
    }
    
    UIViewController *vc = (UIViewController *) value;
    [self.revealControllerDelegate onPresentController:vc previousController:self];

    
}

- (void)onPresentController:(UIViewController *)controller previousController:(UIViewController *)previousController {
    NSLog(@"onPresentController with delegate %@", self.revealControllerDelegate);
    [self.revealControllerDelegate onPresentController:controller previousController:previousController];
}


@end
