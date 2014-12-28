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

- (id)initWithMyId:(NSString *)nmyid success:(void (^)(void))nsuccessBlock error:(void (^)(NSString *))nerrorBlock loading:(void (^)(void))nloadingBlock {
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
        
        mydbq = [DBQ sharedInstance];
        
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
    
    if ([message.fromPeerId isEqualToString:@"0"]) {
        NSLog(@"Root message: %@", message.payload);
        NSError *error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message.payload dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return;
        }
        
        NSString *action = [dict objectForKey:@"action"];
        if ([action isEqualToString:@"deleteFriend"]) {
            NSNumber *uid = [NSNumber numberWithInteger:[[dict objectForKey:@"uid"] integerValue]];
            NSDictionary *userinfo = @{@"uid": uid};
            
            [mydbq deleteConversationWithUid:uid];
            [mydbq deleteFriendWithUid:uid];
            
            [mySession unwatchPeerIds:@[[uid stringValue]] callback:^(BOOL succeeded, NSError *error) {}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NCdeleteFriend" object:self userInfo:userinfo];
        }
        
        return;
    }
    
    NSNumber *uid = [NSNumber numberWithInteger:[message.fromPeerId integerValue]];
    NSString *content = message.payload;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp/1000];
    NSDictionary *dict = @{@"uid": uid, @"content": content, @"date": date};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedMessage" object:self userInfo:dict];
}

- (void)session:(AVSession *)session messageSendFinished:(AVMessage *)message {
    for (MsgQueueItem *item in msgQueue) {
        if (item.message == message) {
            if (item.successBlock) {
                item.successBlock();
            }
            [mydbq setRowId:item.rowID Sending:NO error:NO];
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
            [mydbq setRowId:item.rowID Sending:NO error:YES];
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
    
    NSDate *date = [NSDate date];
    NSNumber *fuid = [NSNumber numberWithInteger:[item.message.toPeerId integerValue]];
    NSNumber *rowID = [mydbq addConversationRowContent:item.message.payload date:date fUId:fuid senderUId:myUId unread:NO error:NO sending:YES];
    item.rowID = rowID;
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
    NSLog(@"%@", @"Signed");

    [avSignature setTimestamp:timestamp];
    [avSignature setNonce:nonce];
    [avSignature setSignature:signature];;
    [avSignature setSignedPeerIds:watchedPeerIds];
    return avSignature;
}

- (AVSession *)getSession {
    return mySession;
}

- (void)setMyUId:(NSNumber *)nuid {
    myUId = nuid;
}

@end
