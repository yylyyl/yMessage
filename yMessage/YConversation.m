//
//  YConversation.m
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "YConversation.h"

@implementation YConversationRow

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        rowDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    
    return self;
}

- (NSNumber *)getUID {
    return [rowDict objectForKey:@"uid"];
}

- (NSString *)getContent {
    return [rowDict objectForKey:@"content"];
}

- (NSDate *)getDate {
    return [rowDict objectForKey:@"date"];
}

- (BOOL)isSending {
    return [[rowDict objectForKey:@"sending"] boolValue];
}

- (BOOL)isError {
    return [[rowDict objectForKey:@"error"] boolValue];
}

- (void)sent {
    [rowDict setObject:@NO forKey:@"sending"];
}

- (void)error {
    [rowDict setObject:@YES forKey:@"error"];
}

@end

@implementation YConversation

- (id)initWithArray:(NSMutableArray *)array friendUid:(NSNumber *)uid {
    self = [super init];
    if (self) {
        conversationArray = array;
        friendUid = uid;
    }
    
    return self;
}

- (NSNumber *)getFriendUid {
    return friendUid;
}

- (YConversationRow *)getLatestRow {
    return [conversationArray lastObject];
}

- (NSMutableArray *)getConversationArray {
    return conversationArray;
}

@end
