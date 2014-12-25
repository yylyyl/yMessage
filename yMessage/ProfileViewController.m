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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"真的要注销？" message:@"所有聊天记录将会被删除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotification" object:self];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
@end
