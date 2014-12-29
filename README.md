yMessage
========
这是一个简单的**私密**聊天软件。
只有用户面对面、同时输入相同的数字后，才能加为好友。

#技术细节
##即时通信
即时通信的实现使用了 [LeanCloud](https://leancloud.cn) 的 [LeadMessage](https://leancloud.cn/features/message.html) 服务，用户系统则是自行实现的（代码未开源），通过对聊天请求的签名实现权限控制。

![image](https://leancloud.cn/docs/images/signature.png)

采用 LeadMessage 不仅大大减少了实现即时通信服务的代码量，同时也能轻松地整合 APNS (Apple Push Notification Service) 服务。

##持久化
yMessage 使用了 SQLite 来存储聊天记录和好友列表。

#本项目中包含以下项目的代码
[FMDB](https://github.com/ccgus/fmdb)

[MBProgressHUD](https://github.com/jdg/MBProgressHUD)

[STHTTPRequest](https://github.com/nst/STHTTPRequest)

[AFNetworking](https://github.com/AFNetworking/AFNetworking)

[CocoaSecurity](https://github.com/kelp404/CocoaSecurity)
