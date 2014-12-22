//
//  AddFriendViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/1.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField1;

- (IBAction)cancelButtonPressed:(id)sender;

@end
