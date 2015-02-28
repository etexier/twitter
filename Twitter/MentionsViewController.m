//
//  MentionsViewController.m
//  Twitter
//
//  Created by Emmanuel Texier on 2/27/15.
//  Copyright (c) 2015 Emmanuel Texier. All rights reserved.
//

#import "MentionsViewController.h"
#import "RevealViewController.h"

@interface MentionsViewController ()

@end

@implementation MentionsViewController
- (id) init {
    self = [super init];
    if (self) {
        self.title = @"Mentions";
    }
    return self;
}

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
        [self.revealControllerDelegate onPanGesture:sender onController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
