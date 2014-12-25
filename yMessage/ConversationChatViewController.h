//
//  ConversationChatTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/11/11.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"
#import "YConversation.h"

@interface ConversationChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    
    YMessageManager *manager;
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyBoardHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)sendButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) YConversation *conversation;

@end
