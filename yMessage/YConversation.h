//
//  YConversation.h
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YConversationRow : NSObject {
    NSDictionary *rowDict;
}

- (id)initWithDict:(NSDictionary *)dict;
- (NSNumber *)getUID;
- (NSString *)getContent;
- (NSDate *)getDate;

@end

@interface YConversation : NSObject {
    NSMutableArray *conversationArray;
    NSNumber *friendUid;
}

- (id)initWithArray:(NSMutableArray *)array friendUid:(NSNumber *)uid;
- (NSNumber *)getFriendUid;
- (NSString *)getLatestText;
- (NSDate *)getLatestDate;
- (NSMutableArray *)getConversationArray;

@end
