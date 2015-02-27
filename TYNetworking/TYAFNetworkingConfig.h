//
//  TYAFNetworkingConfig.h
//  ticket99
//
//  Created by jianzhong on 28/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#ifndef ticket99_TYAFNetworkingConfig_h
#define ticket99_TYAFNetworkingConfig_h

#import "NSDictionary+TYAFNetworking.h"
#import "NSArray+TYAFNetworking.h"

static NSTimeInterval kAIFNetworkingTimeoutSeconds = 20.0f;


typedef NS_ENUM(NSInteger, ResponseStatus){
    ResponseStatusSuccess,//在最底层，当服务器有返回消息就会返回成功
    ResponseStatusErrorTimeout,//当没有收到成功或失败的反馈，当做超时处理
    ResponseStatusErrorFail//默认所有除了超时的网络错误都当做请求失败吃力
};

#endif
