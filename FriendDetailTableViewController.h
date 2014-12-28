//
//  FriendDetailTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/23.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"
#import "DBQ.h"

@interface FriendDetailTableViewController : UITableViewController {
    YMessageManager *manager;
    BOOL deleted;
}

@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSNumber *uid;

@end
