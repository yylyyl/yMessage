//
//  AddFriendViewController.h
//  yMessage
//
//  Created by yangyiliang on 14/12/1.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMessageManager.h"

@interface AddFriendViewController : UIViewController <UITextFieldDelegate> {
    YMessageManager *manager;
}

@property (weak, nonatomic) IBOutlet UITextField *textField1;
@property (weak, nonatomic) IBOutlet UITextField *textField2;
@property (weak, nonatomic) IBOutlet UITextField *textField3;
@property (weak, nonatomic) IBOutlet UITextField *textField4;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)editingChanged:(id)sender;

- (IBAction)donePressed:(id)sender;

@end
