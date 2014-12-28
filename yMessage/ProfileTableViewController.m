//
//  ProfileViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/24.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self logoutPressed:self];
    }
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"真的要注销？" message:@"所有聊天记录将会被删除" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"注销" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"logoutNotification" object:self];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}
@end
