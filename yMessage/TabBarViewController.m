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
#import "ConversationListTableViewController.h"
#import "MBProgressHUD.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startChat:) name:@"startChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"loginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"logoutNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    YMessageManager *manager = [YMessageManager sharedInstance];
    if (![manager logined]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    } else if (!sessionStarted) {
        [self startSession];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)startSession {
    YMessageManager *manager = [YMessageManager sharedInstance];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view setUserInteractionEnabled:NO];
    
    [manager openConnectSuccess:^(void) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self.view setUserInteractionEnabled:YES];
        sessionStarted = YES;
        
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
        sessionStarted = NO;
        
    } loading:^(void) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.view setUserInteractionEnabled:NO];
        sessionStarted = NO;
    } ];
}

- (void)startChat:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    [self setSelectedIndex:0];
    UINavigationController *navvc = [self.viewControllers firstObject];
    [navvc popToRootViewControllerAnimated:YES];
    
    ConversationListTableViewController *cvc = [[navvc childViewControllers] firstObject];
    [cvc startChat:uid];
}

- (void)loggedIn {
    [self startSession];
    
    [self setSelectedIndex:0];
    UINavigationController *navvc = [self.viewControllers firstObject];
    [navvc popToRootViewControllerAnimated:YES];
}

- (void)loggedOut {
    [self performSegueWithIdentifier:@"login" sender:self];
    YMessageManager *manager = [YMessageManager sharedInstance];
    [manager logout];
}

@end
