
//
//  ConversationListTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "ConversationListTableViewController.h"
#import "ConversationChatViewController.h"
#import "ListTableViewCell.h"

@interface ConversationListTableViewController ()

@end

@implementation ConversationListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    manager = [YMessageManager sharedInstance];
    mydbq = [DBQ sharedInstance];
    conversationArray = [mydbq getConversations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startChat:) name:@"startChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessage:) name:@"sentMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"loginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatViewRefreshed:) name:@"chatViewRefreshed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendDeleted:) name:@"friendDeleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NCdeleteFriend:) name:@"NCdeleteFriend" object:nil];

    
    
    [self checkBadge];
}

- (void)viewDidAppear:(BOOL)animated {
    showingConversation = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    for (YConversation *con in conversationArray) {
        if (con == showingConversation) {
            continue;
        }
        
        while ([[con getConversationArray] count] > 10) {
            [[con getConversationArray] removeObjectAtIndex:0];
        }
    }
    
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [conversationArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"con" forIndexPath:indexPath];
    
    // Configure the cell...
    YConversation *conversation = [conversationArray objectAtIndex:[indexPath row]];
    YConversationRow *row = [conversation getLatestRow];
    cell.contentLabel.text = [row getContent];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM-dd HH:mm";
    fmt.locale = [NSLocale systemLocale];
    NSString* dateString = [fmt stringFromDate:[row getDate]];
    
    cell.timeLabel.text = dateString;
    cell.fromLabel.text = [[mydbq getFriends] objectForKey:[conversation getFriendUid]];

    if ([conversation hasUnread]) {
        cell.hasNewLabel.hidden = NO;
        cell.timeLabel.hidden = YES;
    } else {
        cell.hasNewLabel.hidden = YES;
        cell.timeLabel.hidden = NO;
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        YConversation *con = [conversationArray objectAtIndex:[indexPath row]];
        [mydbq deleteConversationWithUid:[con getFriendUid]];
        [conversationArray removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"chat"]) {
        YConversation *con = nil;
        
        ConversationChatViewController *vc = segue.destinationViewController;
        
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        if (selectedRowIndex) {
            con = [conversationArray objectAtIndex:selectedRowIndex.row];
        } else {
            con = chatConversation;
            chatConversation = nil;
        }
        vc.conversation = con;
        showingConversation = con;
        if ([con hasUnread]) {
            [con setUnread:NO];
            [mydbq setConversationReadUid:[con getFriendUid]];
            
            [self.tableView reloadRowsAtIndexPaths:@[selectedRowIndex] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self checkBadge];
        
    }
}

- (void)startChat:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    for(YConversation *con in conversationArray) {
        if ([[con getFriendUid] isEqualToNumber:uid]) {
            chatConversation = con;
            break;
        }
    }
    if (!chatConversation) {
        chatConversation = [[YConversation alloc] initWithArray:[NSMutableArray array] friendUid:uid];
    }
    
    [self performSegueWithIdentifier:@"chat" sender:self];
}

- (void)sentMessage:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    YConversation *con = [dict objectForKey:@"conversation"];
    
    if ([conversationArray containsObject:con]) {
        NSUInteger indexRow = [conversationArray indexOfObject:con];
        [conversationArray exchangeObjectAtIndex:0 withObjectAtIndex:indexRow];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [conversationArray insertObject:con atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)receivedMessage:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    YConversation *updatedCon = nil;
    
    for (YConversation *con in conversationArray) {
        if ([[con getFriendUid] isEqualToNumber:uid]) {
            updatedCon = con;
            break;
        }
    }
    
    if (!updatedCon) {
        // new conversation
        
        NSMutableArray *array = [NSMutableArray array];
        YConversationRow *row = [[YConversationRow alloc] initWithDict:dict];
        [array addObject:row];
        updatedCon = [[YConversation alloc] initWithArray:array friendUid:uid];
        [updatedCon setUnread:YES];
        [conversationArray insertObject:updatedCon atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [mydbq addConversationRowContent:[row getContent] date:[row getDate] fUId:[row getUID] senderUId:[row getUID] unread:YES error:NO sending:NO];
        
        [[self navigationController] tabBarItem].badgeValue = @"!";
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];

    } else {
        // existing conversation
        YConversationRow *row = [[YConversationRow alloc] initWithDict:dict];
        
        if (showingConversation != updatedCon) {
            // not in conversation view
            
            NSMutableArray *array = [updatedCon getConversationArray];
            [array addObject:row];
            [updatedCon setUnread:YES];
            [mydbq addConversationRowContent:[row getContent] date:[row getDate] fUId:[row getUID] senderUId:[row getUID] unread:YES error:NO sending:NO];
            
            [[self navigationController] tabBarItem].badgeValue = @"!";
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
        } else {
            [mydbq addConversationRowContent:[row getContent] date:[row getDate] fUId:[row getUID] senderUId:[row getUID] unread:NO error:NO sending:NO];
        }
        
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:[conversationArray indexOfObject:updatedCon] inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
    {
        AudioServicesPlaySystemSound (1352); //works ALWAYS as of this post
    }
    else
    {
        // Not an iPhone, so doesn't have vibrate
        // play the less annoying tick noise or one of your own
        AudioServicesPlayAlertSound (1105);
    }
}

- (void)chatViewRefreshed:(NSNotification *)notification {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)friendDeleted:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    if (showingConversation && [[showingConversation getFriendUid] isEqualToNumber:uid]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    for (YConversation *con in conversationArray) {
        if ([[con getFriendUid] isEqualToNumber:uid]) {
            [conversationArray removeObject:con];
            break;
        }
    }
    
    [self.tableView reloadData];
    
}

- (void)checkBadge {
    BOOL unread = NO;
    for (YConversation *con in conversationArray) {
        if ([con hasUnread]) {
            unread = YES;
            
            break;
        }
    }
    if (unread) {
        [[self navigationController] tabBarItem].badgeValue = @"!";
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 1];
    } else {
        [[self navigationController] tabBarItem].badgeValue = nil;
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

- (void)loggedIn {
    conversationArray = [mydbq getConversations];
    [self.tableView reloadData];
    
    [self checkBadge];
}

- (void)NCdeleteFriend:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    if (showingConversation && [[showingConversation getFriendUid] isEqualToNumber:uid]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

    conversationArray = [mydbq getConversations];
    
    [self.tableView reloadData];
    [self checkBadge];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Deleted a friend" message:@"Because this friend deleted you from his/her friend list. :(" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [self.tabBarController presentViewController:alert animated:YES completion:nil];
}

@end
