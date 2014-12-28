//
//  ConversationListTableViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"
#import "DBQ.h"

@interface ConversationListTableViewController : UITableViewController {
    YMessageManager *manager;
    NSMutableArray *conversationArray;
    
    YConversation *chatConversation;
    YConversation *showingConversation;
    DBQ *mydbq;
}

@end
