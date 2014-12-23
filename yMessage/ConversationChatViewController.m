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
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, 44, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableView.scrollIndicatorInsets.top, self.tableView.scrollIndicatorInsets.left, 44, self.tableView.scrollIndicatorInsets.right);
    tableViewOldInsets = self.tableView.contentInset;
    tableViewScrollOldInsets = self.tableView.scrollIndicatorInsets;
    
    manager = [YMessageManager sharedInstance];
    self.navigationItem.title = [[manager getFriendsDict] objectForKey:[self.conversation getFriendUid]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar.layer removeAllAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGRect finalKeyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    
    int kbHeight = finalKeyboardFrame.size.height;
    
    //int height = kbHeight + self.textViewBottomConst.constant;
    
    //self.textViewBottomConst.constant = height;
    self.keyBoardHeightConstraint.constant = kbHeight;
    
    //tableViewOldInsets = self.tableView.contentInset;
    //tableViewScrollOldInsets   = self.tableView.scrollIndicatorInsets;
    self.tableView.contentInset = UIEdgeInsetsMake(tableViewOldInsets.top, tableViewOldInsets.left, kbHeight + 44, tableViewOldInsets.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewScrollOldInsets.top, tableViewScrollOldInsets.left, kbHeight + 44, tableViewScrollOldInsets.right);
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    
    self.keyBoardHeightConstraint.constant = 0;
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.tableView.contentInset = tableViewOldInsets;
    self.tableView.scrollIndicatorInsets = tableViewScrollOldInsets;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Table view data source

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
    if ([[row getUID] isEqualToNumber:[manager getUID]]) {
        cell.fromLabel.text = @"我";
    } else {
        cell.fromLabel.text = [[manager getFriendsDict] objectForKey:[row getUID]];
    }
    cell.contentLabel.text = [row getContent];
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = kCFDateFormatterNoStyle;
    fmt.timeStyle = kCFDateFormatterShortStyle;
    fmt.locale = [NSLocale systemLocale];
    NSString* dateString = [fmt stringFromDate:[row getDate]];
    
    cell.timeLabel.text = dateString;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendButtonPressed:(id)sender {
    
    NSInteger trow = [[self.conversation getConversationArray] count];
    YConversationRow *row = [[YConversationRow alloc] initWithDict:@{@"uid": [manager getUID], @"content": self.textField.text, @"date": [NSDate date]}];
    
    [[self.conversation getConversationArray] addObject:row];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    self.textField.text = @"";
    
}
@end
