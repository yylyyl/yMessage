//
//  FriendsListTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"
#import "AddFriendViewController.h"
#import "FriendDetailTableViewController.h"

@interface FriendsListTableViewController : UITableViewController<AddFriendViewControllerDelegate> {
    YMessageManager *manager;
    NSMutableDictionary *friendsDict;
    NSArray *allUIDs;
}

- (IBAction)deleteFriend:(UIStoryboardSegue *)segue;

@end
