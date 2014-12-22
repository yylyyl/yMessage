//
//  TabBarViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/12/22.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "TabBarViewController.h"
#import "YMessageManager.h"
#import "LoginTableViewController.h"
#import "MBProgressHUD.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    YMessageManager *manager = [YMessageManager sharedInstance];
    if (![manager logined]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    } else {
        [self startSession];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"login"]) {
        UINavigationController *navvc = segue.destinationViewController;
        LoginTableViewController *vc = [navvc.childViewControllers firstObject];
        vc.afterLoginBlock = ^(void) {
            [self startSession];
        };
    }
}

- (void)startSession {
    YMessageManager *manager = [YMessageManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    
    [manager openConnectSuccess:^(void) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
    } error:^(NSString *errorString) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed to connect to server" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self startSession];
        }];
        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Re-login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self performSegueWithIdentifier:@"login" sender:self];
        }];
        [alert addAction:retryAction];
        [alert addAction:loginAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
