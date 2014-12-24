//
//  LoginTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/22.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)usernameReturn:(id)sender;
- (IBAction)passwordReturn:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
