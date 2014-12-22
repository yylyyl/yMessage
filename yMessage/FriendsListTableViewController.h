//
//  FriendsListTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"

@interface FriendsListTableViewController : UITableViewController {
    YMessageManager *manager;
    NSMutableDictionary *friendsDict;
    NSArray *allUIDs;
}

@end
