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
        rowDict = dict;
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

- (NSString *)getLatestText {
    YConversationRow *row = [conversationArray lastObject];
    return [row getContent];
}

- (NSDate *)getLatestDate {
    YConversationRow *row = [conversationArray lastObject];
    return [row getDate];
}

- (NSMutableArray *)getConversationArray {
    return conversationArray;
}

@end
