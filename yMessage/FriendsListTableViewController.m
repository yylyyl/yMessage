//
//  FriendsListTableViewController.m
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "FriendsListTableViewController.h"

@interface FriendsListTableViewController ()

@end

@implementation FriendsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    manager = [YMessageManager sharedInstance];
    
    friendsDict = [[DBQ sharedInstance] getFriends];
    allUIDs = [friendsDict allKeys];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"loginNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NCdeleteFriend:) name:@"NCdeleteFriend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendAdded) name:@"friendAdded" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    showingFriendUID = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allUIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend" forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friend"];
    }
    
    cell.textLabel.text = [friendsDict objectForKey:[allUIDs objectAtIndex:indexPath.row]];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
    if ([segue.identifier isEqualToString:@"addfriend"]) {
        UINavigationController *navvc = segue.destinationViewController;
        AddFriendViewController *vc = [navvc.childViewControllers firstObject];
        vc.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showFriend"]) {
        FriendDetailTableViewController *vc = segue.destinationViewController;
        vc.uid = [allUIDs objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        vc.screenName = [friendsDict objectForKey:[allUIDs objectAtIndex:[[self.tableView indexPathForSelectedRow] row]]];
        
        showingFriendUID = vc.uid;
    }
}

- (void)reloadList {
    friendsDict = [[DBQ sharedInstance] getFriends];
    allUIDs = [friendsDict allKeys];
    
    [self.tableView reloadData];
}


- (IBAction)deleteFriend:(UIStoryboardSegue *)segue {
    [self reloadList];
}

- (void)loggedIn {
    [self reloadList];
}

- (void)NCdeleteFriend:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    NSNumber *uid = [dict objectForKey:@"uid"];
    
    if (showingFriendUID && [showingFriendUID isEqualToNumber:uid]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [friendsDict removeObjectForKey:uid];
    allUIDs = [friendsDict allKeys];
    [self.tableView reloadData];
    
}

- (void)friendAdded {
    [self reloadList];
}

@end
