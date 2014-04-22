//
//  RequestManager.h
//  TestASI
//
//  Created by jianzhongliu on 4/1/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASI/ASIHTTPRequest.h"
@interface RequestManager : NSObject<ASIHTTPRequestDelegate>

+ (instancetype)shareReachability;
- (void)firstRequest:(NSString *)path;

@end
