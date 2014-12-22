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
    "CREATE TABLE IF NOT EXISTS conversation_rows (id integer primary key, conid integer not null, uid integer not null, timestamp integer not null, content text not null);"
    "CREATE TABLE IF NOT EXISTS conversations (id integer primary key, uid integer not null);";
    
    if (![mydb executeUpdate:createTableSQL]) {
        NSLog(@"%@", mydb.lastErrorMessage);
    };
}

- (void)close {
    [mydb close];
}

- (NSMutableDictionary *)getFriends {
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM friends"];
    NSMutableDictionary *tmpDict = [NSMutableDictionary dictionary];
    while ([s next]) {
        NSNumber *uid = [NSNumber numberWithUnsignedInt:[s intForColumn:@"uid"]];
        NSString *screen_name = [s stringForColumn:@"screen_name"];
        [tmpDict setObject:screen_name forKey:uid];
    }
    
    return tmpDict;
}

- (void)addFriendWith:(NSNumber *)uid screenName:(NSString *)screenName {
    [mydb executeUpdate:@"INSERT INTO friends(uid, screen_name) VALUES(?, ?)", uid, screenName];
}

- (NSMutableArray *)getConversationArrayWithConId:(NSUInteger)conid {
    NSNumber *conidNumber = [NSNumber numberWithUnsignedInt:conid];
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM conversation_rows WHERE conid=? ORDER BY id DESC LIMIT 0, 20", conidNumber];
    NSMutableArray *tmpArray = [NSMutableArray array];
    while ([s next]) {
        NSString *content = [s stringForColumn:@"content"];
        NSDate *date = [s dateForColumn:@"timestamp"];
        NSNumber *uid = [NSNumber numberWithUnsignedInt:[s intForColumn:@"uid"]];
        YConversationRow *row = [[YConversationRow alloc] initWithDict:@{@"content": content, @"date": date, @"uid": uid}];
        [tmpArray addObject:row];
    }
    
    return tmpArray;
}

- (void)addConversationRowWithConId:(NSNumber *)conid content:(NSString *)content date:(NSDate *)date uid:(NSNumber *)uid {
    [mydb executeUpdate:@"INSERT INTO conversation_rows (conid, content, timestamp, uid) VALUES(?, ?, ?, ?)", conid, content, [NSNumber numberWithUnsignedInteger:[date timeIntervalSince1970]], uid];
}

- (NSMutableArray *)getConversations {
    FMResultSet *s = [mydb executeQuery:@"SELECT * FROM conversations"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    while ([s next]) {
        NSMutableArray *conArray = [self getConversationArrayWithConId:[s intForColumn:@"id"]];
        NSNumber *uid = [NSNumber numberWithUnsignedInteger:[s intForColumn:@"uid"]];
        YConversation *con = [[YConversation alloc] initWithArray:conArray friendUid:uid];
        [tmpArray addObject:con];
    }
    
    return tmpArray;
}

@end
