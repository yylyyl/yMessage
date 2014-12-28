//
//  RegisterTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/28.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"

@interface RegisterTableViewController : UITableViewController {
    YMessageManager *manager;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *screenNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *repeatField;

- (IBAction)submitPressed:(id)sender;
- (IBAction)usernameReturn:(id)sender;
- (IBAction)screenNameReturn:(id)sender;
- (IBAction)passwordReturn:(id)sender;
- (IBAction)repeatReturn:(id)sender;

@end
