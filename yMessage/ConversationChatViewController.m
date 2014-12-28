
//
//  ConversationChatTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/11/11.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "ConversationChatViewController.h"
#import "ConversationTableViewCell.h"

@interface ConversationChatViewController ()

@end

@implementation ConversationChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessage:) name:@"receivedMessage" object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0);
    
    manager = [YMessageManager sharedInstance];
    self.navigationItem.title = [[[DBQ sharedInstance] getFriends] objectForKey:[self.conversation getFriendUid]];

    firstload = YES;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row && firstload){
        //end of loading
        //for example [activityIndicator stopAnimating];
        if ([[self.conversation getConversationArray] count]) {
            animating = YES;
            [CATransaction begin];
            [CATransaction setCompletionBlock: ^{
                animating = NO;
            }];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[self.conversation getConversationArray] count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            [CATransaction commit];
        }
        
        firstload = NO;
    }
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self.conversation getConversationArray] count]) {
        animating = YES;
        [CATransaction begin];
        [CATransaction setCompletionBlock: ^{
            animating = NO;
        }];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[self.conversation getConversationArray] count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        [CATransaction commit];
    }
    
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    while ([[self.conversation getConversationArray] count] > 20) {
        [[self.conversation getConversationArray] removeObjectAtIndex:0];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGRect finalKeyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    
    int kbHeight = finalKeyboardFrame.size.height;
        
    //self.textViewBottomConst.constant = height;
    self.keyBoardHeightConstraint.constant = kbHeight;
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, kbHeight + 44, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, kbHeight + 44, 0);
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if ([[self.conversation getConversationArray] count]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[self.conversation getConversationArray] count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    self.keyBoardHeightConstraint.constant = 0;
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 44, 0);
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
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
    return [[self.conversation getConversationArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msg" forIndexPath:indexPath];
    
    // Configure the cell...
    YConversationRow *row = [[self.conversation getConversationArray] objectAtIndex:indexPath.row];
    
    [self configureCell:row cell:cell];
    
    return cell;
}

- (void)configureCell:(YConversationRow *)row cell:(ConversationTableViewCell *)cell {    
    if ([[row getUID] isEqualToNumber:[manager getUID]]) {
        cell.fromLabel.text = @"我";
        cell.backgroundColor = [UIColor colorWithRed:240.0/255 green:1 blue:240.0/255 alpha:1];
    } else {
        cell.fromLabel.text = [[[DBQ sharedInstance] getFriends] objectForKey:[row getUID]];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.contentLabel.text = [row getContent];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = kCFDateFormatterNoStyle;
    fmt.timeStyle = kCFDateFormatterShortStyle;
    fmt.locale = [NSLocale systemLocale];
    NSString* dateString = [fmt stringFromDate:[row getDate]];
    
    cell.timeLabel.text = dateString;
    if ([row isSending]) {
        [cell.indicator startAnimating];
        cell.timeLabel.hidden = YES;
    } else {
        [cell.indicator stopAnimating];
        cell.timeLabel.hidden = NO;
    }
    
    if ([row isError]) {
        [cell.errorLabel setHidden:NO];
    } else {
        [cell.errorLabel setHidden:YES];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendButtonPressed:textField];
    return NO;
}

- (IBAction)sendButtonPressed:(id)sender {
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    
    NSInteger trow = [[self.conversation getConversationArray] count];
    YConversationRow *row = [[YConversationRow alloc] initWithDict:@{@"uid": [manager getUID], @"content": self.textField.text, @"date": [NSDate date], @"sending": @YES}];
    
    [[self.conversation getConversationArray] addObject:row];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    MsgQueueItem *item = [[MsgQueueItem alloc] init];
    YMsgComm *comm = [manager getComm];
    item.message = [AVMessage messageForPeerWithSession:[comm getSession] toPeerId:[[self.conversation getFriendUid] stringValue] payload:self.textField.text];
    item.successBlock = ^(void) {
        [row sent];
        while (animating) {
            usleep(10000);
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    };
    item.errorBlock = ^(NSString *errorString) {
        [row sent];
        [row error];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed to send message" message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    };
    [comm sendMessage:item];
    
    self.textField.text = @"";
    
    animating = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        animating = NO;
    }];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:trow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [CATransaction commit];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sentMessage" object:self userInfo:@{@"conversation": self.conversation}];
    
}

- (void)receivedMessage:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    if (![uid isEqualToNumber:[self.conversation getFriendUid]]) {
        return;
    }
    
    YConversationRow *row = [[YConversationRow alloc] initWithDict:dict];
    NSMutableArray *array = [self.conversation getConversationArray];
    [array addObject:row];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[array count] - 1 inSection:0];
    while (animating) {
        usleep(10000);
    }
    animating = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        animating = NO;
    }];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    [CATransaction commit];
    
    animating = YES;
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        animating = NO;
    }];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[array count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [CATransaction commit];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"chatViewRefreshed" object:self userInfo:nil];
}
@end
