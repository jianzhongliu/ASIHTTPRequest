//
//  TYAPIProxy.m
//  ticket99
//
//  Created by jianzhong on 29/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#import "TYAPIProxy.h"
#import "TYRequestGenerator.h"
#import "TYURLResponse.h"

@implementation TYAPIProxy

#pragma mark - getter && setter
- (NSMutableDictionary *)mapRequestList {
    if (_mapRequestList == nil) {
        _mapRequestList = [NSMutableDictionary dictionary];
    }
    return _mapRequestList;
}

- (AFHTTPRequestOperationManager *)requestOperationManager {
    if (_requestOperationManager == nil) {
        _requestOperationManager = [[AFHTTPRequestOperationManager alloc] init];
        [_requestOperationManager.requestSerializer setValue:@"image/png" forHTTPHeaderField:@"Content-type"];
        [_requestOperationManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
//        [_requestOperationManager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = NO;
        [_requestOperationManager setSecurityPolicy:securityPolicy];
        
    }
    return _requestOperationManager;
}

- (NSNumber *)generateRequestId
{
    if (_requestID == nil) {
        _requestID = @(1);
    } else {
        if ([_requestID integerValue] == NSIntegerMax) {
            _requestID = @(1);
        } else {
            _requestID = @([_requestID integerValue] + 1);
        }
    }
    return _requestID;
}

#pragma mark - mainMethods

+ (instancetype)shareProxy {
    static TYAPIProxy *proxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (proxy == nil) {
            proxy = [[TYAPIProxy alloc] init];
        }
    });
    return proxy;
}

/**
 GET请求
 */
- (NSInteger)callGETWithParams:(NSDictionary *)params identify:(NSString *)identify methodName:(NSString *)methodName successCallBack:(callBackBlock) success faildCallBack:(callBackBlock) fail {
    NSURLRequest *request = [[TYRequestGenerator shareInstance] generateGETRequestWithServiceIdentifier:identify requestParams:params methodName:methodName];
    return [self callAPIWithRequest:request successCallBack:success faildCallBack:fail];
}

/**
 POST 请求
 */
- (NSInteger)callPOSTWithParams:(NSDictionary *)params identify:(NSString *)identify method:(NSString *)method successCallBack:(callBackBlock) success faildCallBack:(callBackBlock)fail {
    NSURLRequest *request = [[TYRequestGenerator shareInstance] generatePOSTRequestWithServiceIdentifier:identify requestParams:params methodName:method];
    return [self callAPIWithRequest:request successCallBack:success faildCallBack:fail];
}

/**
 所有的服务最终都在这里发出，结果也在这里统一处理
 */
- (NSInteger)callAPIWithRequest:(NSURLRequest *) request successCallBack:(callBackBlock) success faildCallBack:(callBackBlock) fail {
    
    NSNumber *requestID = [self generateRequestId];
    
    AFHTTPRequestOperation *requestOperation = [self.requestOperationManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        AFHTTPRequestOperation *storeOperation = self.mapRequestList[requestID];
        if (storeOperation == nil) {
            return ;
        } else {
            [self.mapRequestList removeObjectForKey:requestID];
        }
        TYURLResponse *response = [[TYURLResponse alloc] initWithResponseString:operation.responseString
                                                                            requestId:requestID
                                                                                request:operation.request
                                                                                responseData:operation.responseData
                                                                                status:ResponseStatusSuccess];
        if (success != nil) {
            success(response);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        AFHTTPRequestOperation *storeOperation = self.mapRequestList[requestID];
        if (storeOperation == nil) {
            return ;
        } else {
            [self.mapRequestList removeObjectForKey:requestID];
        }
#warning TODO  这里可以打log
        TYURLResponse *response = [[TYURLResponse alloc] initWithResponseString:operation.responseString
                                                                        requestId:requestID
                                                                          request:operation.request
                                                                     responseData:operation.responseData
                                                                            error:error];
        if (fail != nil) {
            fail(response);
        }
    }];
    
    [[self.requestOperationManager operationQueue] addOperation:requestOperation];
    
    self.mapRequestList[requestID] = requestOperation;
    return [requestID integerValue];
}

- (void)cancelRequestByRequestID:(NSInteger) identify {
    NSNumber *requestID = [NSNumber numberWithInteger:identify];
    AFHTTPRequestOperation *operation = self.mapRequestList[requestID];
    [operation cancel];
    [self.mapRequestList removeObjectForKey:requestID];
}

- (void)cancelAllRequest {
    NSArray *arrayRequestKey = [self.mapRequestList allKeys];
    [arrayRequestKey enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        AFHTTPRequestOperation *operation = self.mapRequestList[obj];
        [operation cancel];
        [self.mapRequestList removeObjectForKey:obj];
    }];
}

#pragma maik - utilMehods



@end
