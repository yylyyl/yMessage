//
//  YMessageManager.h
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBQ.h"
#import "YConversation.h"
#import "YMsgComm.h"

@interface YMessageManager : NSObject {
    NSMutableDictionary *friendsDict;
    NSMutableArray *conversationArray;
    DBQ *mydbq;
    NSUserDefaults *userDefaults;
    YMsgComm *comm;
    
    NSNumber *matchid;
}

+ (YMessageManager*)sharedInstance;

- (NSMutableDictionary *)getFriendsDict;
- (NSMutableArray *)getConversationArray;

- (void)loginUsername:(NSString *)loginusername password:(NSString *)password success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock;
- (BOOL)logined;

- (void)openConnectSuccess:(void (^)(void))successBlock  error:(void (^)(NSString *))errorBlock;
@end
