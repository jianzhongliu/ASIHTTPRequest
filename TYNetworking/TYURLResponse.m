//
//  TYURLResponse.m
//  ticket99
//
//  Created by jianzhong on 29/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#import "TYURLResponse.h"
#import "NSURLRequest+TYAFNetworking.h"

@interface TYURLResponse ()

@property (nonatomic, assign, readwrite) ResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation TYURLResponse

#pragma mark - life cycle
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(ResponseStatus)status
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        } else {
            self.content = nil;
        }
    }
    return self;
}

#pragma mark - private methods
- (ResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        ResponseStatus result = ResponseStatusSuccess;
        
        // 除了超时以外，所有错误都当成是请求失败
        if (error.code == NSURLErrorTimedOut) {
            result = ResponseStatusErrorFail;
        }
        return result;
    } else {
        return ResponseStatusSuccess;
    }
}

@end
