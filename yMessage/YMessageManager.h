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
- (void)logout;
- (BOOL)logined;
- (NSNumber *)getUID;
- (NSString *)getScreenName;

- (void)openConnectSuccess:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock loading:(void (^)(void))loadingBlock;
- (YMsgComm *)getComm;

- (void)checkFriendWithNumberString:(NSString *)numStr success:(void (^)(NSString *))successBlock error:(void (^)(NSString *))errorBlock;
- (void)acceptFriendSuccess:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock;
- (void)checkAcceptSuccess:(void (^)(BOOL))successBlock error:(void (^)(NSString *))errorBlock;

@end
