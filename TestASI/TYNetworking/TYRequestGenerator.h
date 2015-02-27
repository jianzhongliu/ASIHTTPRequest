//
//  TYRequestGenerator.h
//  ticket99
//
//  Created by jianzhong on 28/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "TYAFNetworkingConfig.h"

/**
 这个类存在的意义是生成一个request
 */

@interface TYRequestGenerator : NSObject

+ (instancetype)shareInstance;

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName;

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName;

@end
