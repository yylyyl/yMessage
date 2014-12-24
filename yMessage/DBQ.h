//
//  DBQ.h
//  yMessage
//
//  Created by yangyiliang on 14/12/21.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "YConversation.h"

@interface DBQ : NSObject {
    FMDatabase *mydb;
}

+ (DBQ *)sharedInstance;
- (void)open;
- (void)close;
- (void)clearAllData;

- (NSMutableDictionary *)getFriends;
- (NSMutableArray *)getConversations;

- (void)addFriendWith:(NSNumber *)uid screenName:(NSString *)screenName;
- (void)addConversationRowWithConId:(NSNumber *)conid content:(NSString *)content date:(NSDate *)date uid:(NSNumber *)uid;

@end
