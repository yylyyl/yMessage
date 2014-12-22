//
//  AddFriendViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/1.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "AddFriendViewController.h"
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.textField1 becomeFirstResponder];
    manager = [YMessageManager sharedInstance];
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

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[AFHTTPRequestOperationManager manager].operationQueue cancelAllOperations];
}

- (IBAction)editingChanged:(id)sender {
    UITextField *textField = sender;
    if ([textField.text length] == 1) {
        NSInteger next = [textField tag] + 1;
        if (next == 5) {
            return;
        }
        
        [[self.view viewWithTag:next] becomeFirstResponder];
    } else if ([textField.text length] == 0 && textField.tag > 1) {
        NSInteger next = [textField tag] - 1;
        [[self.view viewWithTag:next] becomeFirstResponder];
    }
}

- (IBAction)donePressed:(id)sender {
    if ([self.textField1.text isEqualToString:@""]) {
        return;
    }
    if ([self.textField2.text isEqualToString:@""]) {
        return;
    }
    if ([self.textField3.text isEqualToString:@""]) {
        return;
    }
    if ([self.textField4.text isEqualToString:@""]) {
        return;
    }
    
    [self.textField1 resignFirstResponder];
    [self.textField2 resignFirstResponder];
    [self.textField3 resignFirstResponder];
    [self.textField4 resignFirstResponder];
    
    NSString *numberString = [NSString stringWithFormat:@"%@%@%@%@", self.textField1.text, self.textField2.text, self.textField3.text, self.textField4.text];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    
    [self addFriend:numberString];
}

- (void)addFriend:(NSString *)numberString {
    // loop wait...
    [manager checkFriendWithNumberString:numberString success:^(NSString *screenName) {
        if ([screenName isKindOfClass:[NSNull class]]) {
            [self performSelector:@selector(addFriend:) withObject:numberString afterDelay:1];
            NSLog(@"Wait...");
            return;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add this friend?" message:screenName preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [self.view setUserInteractionEnabled:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes!" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self acceptFriend];
        }];
        [alert addAction:noAction];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    } error:^(NSString *errorString) {
        [self showError:errorString];
    }];
}

- (void)checkFriendSuccessCheck:(NSString *)screenName {
    
};

- (void)acceptFriend {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.view setUserInteractionEnabled:NO];
    
    
}

- (void)showError:(NSString *)errorString {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [self.navigationController.navigationBar setUserInteractionEnabled:YES];
    [self.view setUserInteractionEnabled:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed to add friend" message:errorString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.text length] == 0 && [string length] == 1) {
        return YES;
    }
    if ([textField.text length] > 0 && [string length] == 0) {
        return YES;
    }
        
    return NO;
}
@end
