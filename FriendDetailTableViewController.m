//
//  FriendDetailTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/23.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "FriendDetailTableViewController.h"
#import "MBProgressHUD.h"

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
    
    manager = [YMessageManager sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NCdeleteFriend:) name:@"NCdeleteFriend" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (deleted) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你们之间的对话将被删除，您也会从对方的好友列表中消失" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self deleteFriend];
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

- (void)deleteFriend {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [manager deleteFriendWithUid:self.uid success:^(void) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        [[DBQ sharedInstance] deleteConversationWithUid:self.uid];
        [[DBQ sharedInstance] deleteFriendWithUid:self.uid];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"friendDeleted" object:nil userInfo:@{@"uid": self.uid}];
        [self performSegueWithIdentifier:@"deleteFriend" sender:self];
        
    } error:^(NSString *errorString) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed to delete friend" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }];

}

- (void)NCdeleteFriend:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    if ([uid isEqualToNumber:self.uid]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        deleted = YES;
    }
}

@end
