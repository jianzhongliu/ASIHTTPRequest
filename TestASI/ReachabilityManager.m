//
//  ReachabilityManager.m
//  TestASI
//
//  Created by jianzhongliu on 4/1/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import "ReachabilityManager.h"

@implementation ReachabilityManager

+ (instancetype)shareReachability {
    static ReachabilityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[ReachabilityManager alloc] init];
        }
    });
    return manager;
}

//判断当前wifi是否有效，测试结果：guest和b01结果为1;CMCC结果为0;2g=0;
- (BOOL)checkWIFI {
   return [[Reachability reachabilityForLocalWiFi] isReachable];
}

//guest=1；b01=1；cmcc =1；没网时为0；2g=1；
- (BOOL)checkHost {
    return [[Reachability reachabilityWithHostName:@"202.108.23.50"] isReachable];
}

//判断wifi,所有wifi都为true
- (BOOL)checkIsWifi {
    return [[Reachability reachabilityWithHostName:@"202.108.23.50"] isReachableViaWiFi];
}

//判断wwan 仅wwan为true
- (BOOL)checkIsWLAN {
    return [[Reachability reachabilityWithHostName:@"202.108.23.50"] isReachableViaWWAN];
}

@end
