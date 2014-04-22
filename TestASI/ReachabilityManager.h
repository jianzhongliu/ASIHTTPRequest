//
//  ReachabilityManager.h
//  TestASI
//
//  Created by jianzhongliu on 4/1/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface ReachabilityManager : NSObject

+ (instancetype)shareReachability;
- (BOOL)checkWIFI;
- (BOOL)checkHost;
- (BOOL)checkIsWifi;
- (BOOL)checkIsWLAN;
@end
