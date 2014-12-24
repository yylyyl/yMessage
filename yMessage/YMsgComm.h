//
//  YMsgComm.h
//  yMessage
//
//  Created by yangyiliang on 14/12/21.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVOSCloud/AVOSCloud.h>

@interface MsgQueueItem : NSObject
@property (nonatomic, strong) AVMessage *message;
@property (nonatomic, strong) void (^successBlock)(void);
@property (nonatomic, strong) void (^errorBlock)(NSString *);

@end

@interface YMsgComm : NSObject <AVSessionDelegate, AVSignatureDelegate> {
    NSMutableArray *msgQueue;
    NSString *myid;
    AVSession *mySession;
    
    void (^successBlock)(void);
    void (^errorBlock)(NSString *);
    void (^loadingBlock)(void);
    
}

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *hpassword;

- (id)initWithMyId:(NSString *)myid myFriendsIds:(NSArray *)friendsids success:(void (^)(void))nsuccessBlock error:(void (^)(NSString *))nerrorBlock loading:(void (^)(void))nloadingBlock;
- (void)open;
- (void)close;

@end
