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
    conversationArray = [manager getConversationArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startChat:) name:@"startChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sentMessage:) name:@"sentMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([[row getUID] isEqualToNumber:[manager getUID]]) {
        cell.fromLabel.text = @"我";
    } else {
        cell.fromLabel.text = [[manager getFriendsDict] objectForKey:[row getUID]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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
        NSMutableArray *array = [NSMutableArray array];
        YConversationRow *row = [[YConversationRow alloc] initWithDict:dict];
        [array addObject:row];
        updatedCon = [[YConversation alloc] initWithArray:array friendUid:uid];
        [conversationArray insertObject:updatedCon atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];

    } else {
        YConversationRow *row = [[YConversationRow alloc] initWithDict:dict];
        NSMutableArray *array = [updatedCon getConversationArray];
        [array addObject:row];
        
        [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:[conversationArray indexOfObject:updatedCon] inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
