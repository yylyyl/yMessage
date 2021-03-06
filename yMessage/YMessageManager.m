//
//  YMessageManager.m
//  yMessage
//
//  Created by yangyiliang on 14/11/10.
//  Copyright (c) 2014年 yylyyl. All rights reserved.
//

#import "YMessageManager.h"
#import "AFNetworking.h"
#import "CocoaSecurity.h"

@implementation YMessageManager

+ (YMessageManager*)sharedInstance
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
        //friendsArray = [NSArray array];
        
        //YFriend *f1 = [[YFriend alloc] initWithDict:@{@"screen_name": @"yylyyl", @"uid": @1}];
        //YFriend *f2 = [[YFriend alloc] initWithDict:@{@"screen_name": @"user2", @"uid": @2}];
        //YFriend *f3 = [[YFriend alloc] initWithDict:@{@"screen_name": @"user3", @"uid": @3}];
        //YFriend *f4 = [[YFriend alloc] initWithDict:@{@"screen_name": @"user4", @"uid": @4}];
        
        //YConversation *conversation = [[YConversation alloc] init];
        
        //friendsArray = @[f1, f2, f3, f4];
        //conversationArray = @[conversation, conversation, conversation, conversation];
        
        mydbq = [DBQ sharedInstance];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)openConnectSuccess:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock loading:(void (^)(void))loadingBlock {
    NSString *myIdString = [[self getUID] stringValue];
    comm = [[YMsgComm alloc] initWithMyId:myIdString success:successBlock error:errorBlock loading:loadingBlock];
    comm.username = [self getUsername];
    comm.hpassword = [self getHashedPassword];
    [comm open];
    [comm setMyUId:[self getUID]];
}

- (YMsgComm *)getComm {
    return comm;
}

- (void)registerUsername:(NSString *)loginusername screenName:(NSString *)screenname password:(NSString *)password success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    
    NSLog(@"%@", @"try to register");
    NSString *hpassword = [CocoaSecurity md5:password].hexLower;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": loginusername, @"hpassword": hpassword, @"screen_name": screenname};
    [manager GET:@"http://yyl.im/ym/register.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        NSLog(@"%@", d);
        
        NSNumber *uid = [NSNumber numberWithInteger:[[d objectForKey:@"uid"] integerValue]];
        NSString *screen_name = [d objectForKey:@"screen_name"];
        
        [userDefaults setObject:loginusername forKey:@"username"];
        [userDefaults setObject:hpassword forKey:@"hpassword"];
        [userDefaults setInteger:[uid unsignedIntegerValue] forKey:@"uid"];
        [userDefaults setObject:screen_name forKey:@"screen_name"];
        [userDefaults synchronize];
        
        // load friend list
        NSArray *friends = [d objectForKey:@"friends"];
        for (NSDictionary *f in friends) {
            NSNumber *fuid = [NSNumber numberWithInteger:[[f objectForKey:@"id"] integerValue]];
            NSString *fname = [f objectForKey:@"screen_name"];
            [mydbq addFriendWith:fuid screenName:fname];
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];
}

- (void)loginUsername:(NSString *)loginusername password:(NSString *)password success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    
    NSLog(@"%@", @"try to login");
    NSString *hpassword = [CocoaSecurity md5:password].hexLower;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": loginusername, @"hpassword": hpassword};
    [manager GET:@"http://yyl.im/ym/login.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        NSLog(@"%@", d);
        
        NSNumber *uid = [NSNumber numberWithInteger:[[d objectForKey:@"uid"] integerValue]];
        NSString *screen_name = [d objectForKey:@"screen_name"];
        
        [userDefaults setObject:loginusername forKey:@"username"];
        [userDefaults setObject:hpassword forKey:@"hpassword"];
        [userDefaults setInteger:[uid unsignedIntegerValue] forKey:@"uid"];
        [userDefaults setObject:screen_name forKey:@"screen_name"];
        [userDefaults synchronize];
        
        // load friend list
        NSArray *friends = [d objectForKey:@"friends"];
        for (NSDictionary *f in friends) {
            NSNumber *fuid = [NSNumber numberWithInteger:[[f objectForKey:@"id"] integerValue]];
            NSString *fname = [f objectForKey:@"screen_name"];
            [mydbq addFriendWith:fuid screenName:fname];
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];
}

- (void)logout {
    [comm close];
    
    [userDefaults removeObjectForKey:@"username"];
    [userDefaults removeObjectForKey:@"hpassword"];
    [userDefaults removeObjectForKey:@"uid"];
    [userDefaults removeObjectForKey:@"screen_name"];
    [userDefaults synchronize];

    [mydbq clearAllData];

}

#pragma mark - adding friends

- (void)checkFriendWithNumberString:(NSString *)numStr success:(void (^)(NSString *))successBlock error:(void (^)(NSString *))errorBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": [self getUsername], @"hpassword": [self getHashedPassword], @"num": numStr};
    [manager GET:@"http://yyl.im/ym/check_friend.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        matchid = [NSNumber numberWithInteger:[[d objectForKey:@"matchid"] integerValue]];
        NSString *screen_name = [d objectForKey:@"screen_name"];
        
        if (successBlock) {
            successBlock(screen_name);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];

}

- (void)acceptFriendSuccess:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": [self getUsername], @"hpassword": [self getHashedPassword], @"matchid": matchid};
    [manager GET:@"http://yyl.im/ym/accept_friend.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];
    
}

- (void)checkAcceptSuccess:(void (^)(BOOL))successBlock error:(void (^)(NSString *))errorBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": [self getUsername], @"hpassword": [self getHashedPassword], @"matchid": matchid};
    [manager GET:@"http://yyl.im/ym/accept_check.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        BOOL accept = [[d objectForKey:@"accept"] boolValue];
        
        if (accept) {
            NSString *screenName = [d objectForKey:@"screen_name"];
            NSNumber *uid = [NSNumber numberWithInteger:[[d objectForKey:@"uid"] integerValue]];
            
            [mydbq addFriendWith:uid screenName:screenName];
        }
        
        if (successBlock) {
            successBlock(accept);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];
    
}

- (void)deleteFriendWithUid:(NSNumber *)uid success:(void (^)(void))successBlock error:(void (^)(NSString *))errorBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *args = @{@"username": [self getUsername], @"hpassword": [self getHashedPassword], @"uid": uid};
    [manager GET:@"http://yyl.im/ym/delete_friend.php" parameters:args success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject == nil || ![responseObject isKindOfClass: [NSDictionary class]]) {
            if (errorBlock) {
                errorBlock(@"Unknown error, invalid data");
            }
            return;
        }
        NSDictionary *d = responseObject;
        BOOL isOK = [[d objectForKey:@"ok"] boolValue];
        if (!isOK) {
            NSString *errorString = [d objectForKey:@"error"];
            if (errorBlock) {
                errorBlock(errorString);
            }
            return;
        }
        
        if (successBlock) {
            successBlock();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (errorBlock) {
            errorBlock([error localizedDescription]);
        }
    }];
    
}

#pragma mark - other things


- (NSString *)getHashedPassword {
    return [userDefaults objectForKey:@"hpassword"];
}

- (NSString *)getScreenName {
    return [userDefaults objectForKey:@"screen_name"];
}

- (NSString *)getUsername {
    return [userDefaults objectForKey:@"username"];
}

- (NSNumber *)getUID {
    return [userDefaults objectForKey:@"uid"];
}

- (BOOL)logined {
    if ([self getScreenName]) {
        return YES;
    }
    return NO;
}

@end
