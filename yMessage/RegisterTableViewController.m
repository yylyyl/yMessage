//
//  RegisterTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/28.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "MBProgressHUD.h"

@interface RegisterTableViewController ()

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    manager = [YMessageManager sharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)submitPressed:(id)sender {
    if ([self.usernameField.text isEqualToString:@""]) {
        return;
    }
    if ([self.screenNameField.text isEqualToString:@""]) {
        return;
    }
    if ([self.passwordField.text isEqualToString:@""]) {
        return;
    }
    if ([self.repeatField.text isEqualToString:@""]) {
        return;
    }
    
    [self.usernameField resignFirstResponder];
    [self.screenNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.repeatField resignFirstResponder];
    
    if ([self.passwordField.text isEqualToString:self.repeatField.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"密码不一致" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.navigationController.navigationBar setUserInteractionEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    
    [manager registerUsername:self.usernameField.text screenName:self.screenNameField.text password:self.passwordField.text success:^(void) {
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        [self.view setUserInteractionEnabled:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginNotification" object:self];
        
    } error:^(NSString *errorString) {
        [self.navigationController.navigationBar setUserInteractionEnabled:YES];
        [self.view setUserInteractionEnabled:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (IBAction)usernameReturn:(id)sender {
    [self.screenNameField becomeFirstResponder];
}

- (IBAction)screenNameReturn:(id)sender {
    [self.passwordField becomeFirstResponder];
}

- (IBAction)passwordReturn:(id)sender {
    [self.repeatField becomeFirstResponder];
}

- (IBAction)repeatReturn:(id)sender {
    [self submitPressed:self];
}
@end
