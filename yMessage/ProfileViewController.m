//
//  ProfileViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/24.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"loginNotification" object:nil];
    
    manager = [YMessageManager sharedInstance];
    [self updateScreenName];
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

- (void)updateScreenName {
    self.usernameLabel.text = [manager getScreenName];
}

- (void)loggedIn {
    [self updateScreenName];
}

- (IBAction)logoutPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotification" object:self];
}
@end
