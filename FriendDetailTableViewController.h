//
//  FriendDetailTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/23.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendDetailTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSNumber *uid;

@end
