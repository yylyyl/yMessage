//
//  FriendDetailTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/23.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "FriendDetailTableViewController.h"

@interface FriendDetailTableViewController ()

@end

@implementation FriendDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.screenNameLabel.text = self.screenName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"startChat" object:self userInfo:@{@"uid": self.uid}];
    }
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"删除好友" message:@"你们之间的对话将被删除，您也会从对方的好友列表中消失" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"deleteFriend" sender:self];
        }];
        [alert addAction:noAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
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

@end
