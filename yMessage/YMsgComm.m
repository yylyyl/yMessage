//
//  YMsgComm.m
//  yMessage
//
//  Created by yangyiliang on 14/12/21.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "YMsgComm.h"
#import "STHTTPRequest.h"

@implementation MsgQueueItem

@end

@implementation YMsgComm

- (id)initWithMyId:(NSString *)nmyid myFriendsIds:(NSArray *)friendsids success:(void (^)(void))nsuccessBlock error:(void (^)(NSString *))nerrorBlock loading:(void (^)(void))nloadingBlock {
    self = [super init];
    if (self) {
        msgQueue = [NSMutableArray array];
        
        mySession = [[AVSession alloc] init];
        mySession.sessionDelegate = self;
        mySession.signatureDelegate = self;
        successBlock = nsuccessBlock;
        errorBlock = nerrorBlock;
        loadingBlock = nloadingBlock;
        myid = nmyid;
        
    }
    
    return self;
}

- (void)open {
    [mySession openWithPeerId:myid];
}

- (void)close {
    [mySession close];
}

- (void)sessionOpened:(AVSession *)session {
    NSLog(@"%@", @"sessionOpened");
    if (session.isOpen) {
        if (successBlock) {
            successBlock();
        }
    } else {
        if (errorBlock) {
            errorBlock(@"");
        }
    }
    
}

- (void)sessionFailed:(AVSession *)session error:(NSError *)error {
    NSLog(@"%@ %@", @"sessionFailed", [error localizedDescription]);
}

- (void)sessionPaused:(AVSession *)session {
    NSLog(@"%@", @"sessionPaused");
    if (loadingBlock) {
        loadingBlock();
    }
}

- (void)sessionResumed:(AVSession *)session {
    NSLog(@"%@", @"sessionResumed");
    if (successBlock) {
        successBlock();
    }
}

- (void)session:(AVSession *)session didReceiveMessage:(AVMessage *)message {
    NSLog(@"%@", @"didReceiveMessage");
    
    if (message.type != AVMessageTypePeerIn) {
        NSLog(@"Unknown msg: %@", message);
        return;
    }
    
    NSNumber *uid = [NSNumber numberWithInteger:[message.fromPeerId integerValue]];
    NSString *content = message.payload;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp];
    NSDictionary *dict = @{@"uid": uid, @"content": content, @"date": date};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:self userInfo:dict];
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
    if (![mySession peerIdIsWatching:item.message.toPeerId]) {
        [mySession watchPeerIds:@[item.message.toPeerId]];
    }
    
    [msgQueue addObject:item];
    [mySession sendMessage:item.message];
}

- (AVSignature *)signatureForPeerWithPeerId:(NSString *)peerId watchedPeerIds:(NSArray *)watchedPeerIds action:(NSString *)action {
    if (!watchedPeerIds) {
        return nil;
    }
    NSLog(@"Signature requested for action %@ peeidID %@ watchPeerIds %@", action, peerId, watchedPeerIds);
    
    AVSignature* avSignature=[[AVSignature alloc] init];
    
    STHTTPRequest *r = [STHTTPRequest requestWithURLString:@"http://yyl.im/ym/sign.php"];
    NSString *peerIdsString = [watchedPeerIds componentsJoinedByString:@":"];
    r.GETDictionary = @{ @"peer_id":peerId, @"watch_peer_ids":peerIdsString, @"username": self.username, @"hpassword": self.hpassword };
    r.completionBlock = ^(NSDictionary *headers, NSString *body) {
        NSLog(@"%@", body);
    };
    r.errorBlock = ^(NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    };
    NSError *error = nil;
    [r startSynchronousWithError:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    id object = [NSJSONSerialization
                 JSONObjectWithData:r.responseData
                 options:0
                 error:&error];
    
    if (error) {
        NSLog(@"Get signature error: %@ %@", [error localizedDescription], r.responseString);
        return nil;
    }
    NSInteger timestamp;
    NSString *nonce;
    NSString *signature;
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        timestamp = [[results objectForKey:@"timestamp"] integerValue];
        nonce = [results objectForKey:@"nonce"];
        signature = [results objectForKey:@"signature"];
    }
    else
    {
        NSLog(@"%@ %@", @"Not json?!", r.responseString);
        return nil;
    }

    [avSignature setTimestamp:timestamp];
    [avSignature setNonce:nonce];
    [avSignature setSignature:signature];;
    [avSignature setSignedPeerIds:watchedPeerIds];
    return avSignature;
}

- (AVSession *)getSession {
    return mySession;
}

@end
