//
//  DBQ.m
//  yMessage
//
//  Created by yangyiliang on 14/12/21.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "DBQ.h"

@implementation DBQ

+ (DBQ *)sharedInstance
{
    static dispatch_once_t predicate = 0;
    __strong static id sharedObject = nil;
    //static id sharedObject = nil;  //if you're not using ARC
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
        //sharedObject = [[[self alloc] init] retain]; // if you're not using ARC
    });
    return sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"ymessage.db"];
        
        mydb = [FMDatabase databaseWithPath:appFile];
    }
    
    return self;
}

- (void)open {
    if (![mydb open]) {
        NSLog(@"%@", @"Cannot open db.");
        exit(-1);
    }
    
    NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS friends (id integer primary key, uid integer not null, screen_name text not null);"
    "CREATE TABLE IF NOT EXISTS conversation_rows (id integer primary key, conid integer not null, uid integer not null, timestamp integer not null, content text not null, sending integer not null, errored integer not null);"
    "CREATE TABLE IF NOT EXISTS conversations (id integer primary key, uid integer not null, unread integer not null);";
    
    if (![mydb executeStatements:createTableSQL]) {
        NSLog(@"%@", mydb.lastErrorMessage);
    };
}

- (void)close {
    [mydb close];
}

- (void)clearAllData {
    [self open];
    NSString *dropString = @"DROP TABLE IF EXISTS friends;"
                            "DROP TABLE IF EXISTS conversation_rows;"
                            "DROP TABLE IF EXISTS conversations;";
    [mydb executeStatements:dropString];
    [self close];
}

- (NSMutableDictionary *)getFriends {
    [self open];
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM friends"];
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    while ([s next]) {
        NSNumber *uid = [NSNumber numberWithUnsignedInt:[s intForColumn:@"uid"]];
        NSString *screen_name = [s stringForColumn:@"screen_name"];
        [tmpDict setObject:screen_name forKey:uid];
    }
    [self close];
    
    return tmpDict;
}

- (void)addFriendWith:(NSNumber *)uid screenName:(NSString *)screenName {
    [self open];
    [mydb executeUpdate:@"INSERT INTO friends(uid, screen_name) VALUES(?, ?)", uid, screenName];
    [self close];
}


- (void)deleteFriendWithUid:(NSNumber *)uid {
    [self open];
    [mydb executeUpdate:@"DELETE FROM friends WHERE uid=?", uid];
    [self close];
}

- (NSMutableArray *)getConversationArrayWithConId:(NSUInteger)conid {
    NSNumber *conidNumber = [NSNumber numberWithUnsignedInteger:conid];
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM conversation_rows WHERE conid=? ORDER BY id ASC LIMIT 0, 20", conidNumber];
    NSMutableArray *tmpArray = [NSMutableArray array];
    while ([s next]) {
        NSNumber *rid = [NSNumber numberWithInteger:[s intForColumn:@"id"]];
        NSString *content = [s stringForColumn:@"content"];
        NSDate *date = [s dateForColumn:@"timestamp"];
        NSNumber *uid = [NSNumber numberWithUnsignedInt:[s intForColumn:@"uid"]];
        NSNumber *sending = [NSNumber numberWithBool:[s boolForColumn:@"sending"]];
        NSNumber *error = [NSNumber numberWithBool:[s boolForColumn:@"errored"]];
        YConversationRow *row = [[YConversationRow alloc] initWithDict:@{@"id": rid, @"content": content, @"date": date, @"uid": uid, @"sending": sending, @"error": error}];
        [tmpArray addObject:row];
    }
    
    return tmpArray;
}

- (void)deleteConversationWithUid:(NSNumber *)uid {
    [self open];
    NSString *getConIdSQL = @"SELECT * FROM conversations WHERE uid=?";
    FMResultSet *s = [mydb executeQuery:getConIdSQL, uid];
    if (![s next]) {
        return;
    }
    NSNumber *cid = [NSNumber numberWithInteger:[s intForColumn:@"id"]];
    NSString *deleteConSQL = @"DELETE FROM conversations WHERE uid=?";
    [mydb executeUpdate:deleteConSQL, uid];
    
    NSString *deleteRowSQL = @"DELETE FROM conversation_rows WHERE conid=?";
    [mydb executeUpdate:deleteRowSQL, cid];
    
    [self close];
}

- (void)setRowId:(NSNumber *)rid Sending:(BOOL)sending error:(BOOL)error {
    [self open];
    NSString *sql = @"UPDATE conversation_rows set sending=?, errored=? WHERE id=?";
    [mydb executeUpdate:sql, [NSNumber numberWithBool:sending], [NSNumber numberWithBool:error], rid];
    [self close];
}

- (NSNumber *)addConversationRowContent:(NSString *)content date:(NSDate *)date fUId:(NSNumber *)fuid senderUId:(NSNumber *)senderuid unread:(BOOL)unread error:(BOOL)error sending:(BOOL)sending; {
    [self open];
    NSString *checkConSQL = @"SELECT * FROM conversations WHERE uid=?";
    FMResultSet *s = [mydb executeQuery:checkConSQL, fuid];
    NSNumber *cid;
    if (![s next]) {
        NSString *addConSQL = @"INSERT INTO conversations(uid, unread) VALUES(?, ?)";
        [mydb executeUpdate:addConSQL, fuid, [NSNumber numberWithBool:unread]];
        cid = [NSNumber numberWithInt:(int)[mydb lastInsertRowId]];
    } else {
        cid = [NSNumber numberWithInt:[s intForColumn:@"id"]];
        if ([s boolForColumn:@"unread"] != unread) {
            
            NSString *sql = @"UPDATE conversations set unread=1 WHERE id=?";
            [mydb executeUpdate:sql, cid];
        }
    }
    
    [mydb executeUpdate:@"INSERT INTO conversation_rows (conid, content, timestamp, uid, sending, errored) VALUES(?, ?, ?, ?, ?, ?)",
     cid, content, [NSNumber numberWithUnsignedInteger:[date timeIntervalSince1970]], senderuid,
     [NSNumber numberWithBool:sending], [NSNumber numberWithBool:error]];
    
    NSNumber *rowID = [NSNumber numberWithInteger: (int)[mydb lastInsertRowId]];
    [self close];
    return rowID;
}

- (void)setConversationReadUid:(NSNumber *)uid {
    [self open];
    NSString *sql = @"UPDATE conversations set unread=0 WHERE uid=?";
    [mydb executeUpdate:sql, uid];
    [self close];
}

- (NSMutableArray *)getConversations {
    [self open];
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM conversations"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    while ([s next]) {
        NSMutableArray *conArray = [self getConversationArrayWithConId:[s intForColumn:@"id"]];
        NSNumber *uid = [NSNumber numberWithUnsignedInteger:[s intForColumn:@"uid"]];
        YConversation *con = [[YConversation alloc] initWithArray:conArray friendUid:uid];
        [con setUnread:[s boolForColumn:@"unread"]];
        [tmpArray addObject:con];
    }
    [self close];
    
    [tmpArray sortUsingComparator:^NSComparisonResult(YConversation *obj1, YConversation *obj2) {
        return [[[obj1 getLatestRow] getDate] timeIntervalSince1970] < [[[obj2 getLatestRow] getDate] timeIntervalSince1970];
    }];
    
    return tmpArray;
}

@end
