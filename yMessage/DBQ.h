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
- (void)clearAllData;

- (NSMutableDictionary *)getFriends;
- (NSMutableArray *)getConversations;

- (void)addFriendWith:(NSNumber *)uid screenName:(NSString *)screenName;
- (void)deleteFriendWithUid:(NSNumber *)uid;

- (NSNumber *)addConversationRowContent:(NSString *)content date:(NSDate *)date fUId:(NSNumber *)fuid senderUId:(NSNumber *)senderuid unread:(BOOL)unread error:(BOOL)error sending:(BOOL)sending;
- (void)setConversationReadUid:(NSNumber *)uid;

- (void)setRowId:(NSNumber *)rid Sending:(BOOL)sending error:(BOOL)error;
- (void)deleteConversationWithUid:(NSNumber *)uid;

@end
