//
//  YMsgComm.m
//  yMessage
//
//  Created by yangyiliang on 14/12/21.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "YMsgComm.h"

@implementation YMsgComm

- (id)initWithMyId:(NSString *)myid myFriendsIds:(NSArray *)friendsids success:(void (^)(void))nsuccessBlock error:(void (^)(NSString *))nerrorBlock {
    self = [super init];
    if (self) {
        msgQueue = [NSMutableArray array];
        
        session = [[AVSession alloc] init];
        session.sessionDelegate = self;
        session.signatureDelegate = self;
        successBlock = nsuccessBlock;
        errorBlock = nerrorBlock;
        
        [session openWithPeerId:myid watchedPeerIds:friendsids];
    }
    
    return self;
}

- (void)sessionOpened:(AVSession *)session {
    NSLog(@"%@", @"sessionOpened");
    if (successBlock) {
        successBlock();
    }
}

- (void)sessionFailed:(AVSession *)session error:(NSError *)error {
    NSLog(@"%@ %@", @"sessionFailed", [error localizedDescription]);
    if (errorBlock) {
        errorBlock([error localizedDescription]);
    }
}

- (void)session:(AVSession *)session didReceiveMessage:(AVMessage *)message {
    NSLog(@"%@", @"didReceiveMessage");
}

- (void)session:(AVSession *)session messageSendFinished:(AVMessage *)message {
    for (MsgQueueItem *item in msgQueue) {
        if (item.message == message) {
            if (item.successBlock) {
                item.successBlock();
            }
            [msgQueue removeObject:item];
            break;
        }
    }
}

- (void)session:(AVSession *)session messageSendFailed:(AVMessage *)message error:(NSError *)error {
    for (MsgQueueItem *item in msgQueue) {
        if (item.message == message) {
            if (item.errorBlock) {
                item.errorBlock([error localizedDescription]);
            }
            [msgQueue removeObject:item];
            break;
        }
    }
}

- (void)sendMessage:(MsgQueueItem *)item {
    [msgQueue addObject:item];
    [session sendMessage:item.message];
}

- (AVSignature *)signatureForPeerWithPeerId:(NSString *)peerId watchedPeerIds:(NSArray *)watchedPeerIds action:(NSString *)action {
    NSLog(@"Signature requested for %@", action);
    return nil;
}

@end
