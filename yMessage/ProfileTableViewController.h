//
//  ProfileViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/24.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"

@interface ProfileTableViewController : UITableViewController {
    YMessageManager *manager;
}

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

- (IBAction)logoutPressed:(id)sender;

@end
