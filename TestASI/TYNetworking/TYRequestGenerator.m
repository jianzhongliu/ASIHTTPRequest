//
//  TYRequestGenerator.m
//  ticket99
//
//  Created by jianzhong on 28/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#import "TYRequestGenerator.h"
#import "TYSignatureGenerator.h"

@interface TYRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation TYRequestGenerator

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = kAIFNetworkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

+ (instancetype)shareInstance {
    static TYRequestGenerator *reqest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (reqest == nil) {
            reqest = [[TYRequestGenerator alloc] init];
        }
    });
    return reqest;
}
//老的
////m.ctrip.com/restapi/soa2/10064/json/GetDeliverByAreaId?AreaId=3&
//encode=gbk&
//format=json&
//method=GetDeliverByAreaId&
//reqtime=1422449001&
//TicketTime=2015-01-29%2007%3A20%3A00&
//user=apple&
//version=5.22

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *) requestParams methodName:(NSString *)methodName
{
    NSMutableDictionary *dicParams = [NSMutableDictionary dictionaryWithDictionary:requestParams];
    [dicParams addEntriesFromDictionary:[self commonParams]];
    
    //参数表按字母排序，拼接成字符串
    NSDictionary *dicOrder = [NSDictionary dictionary];
    dicOrder = [TYSignatureGenerator compomentParamsAndOrder:dicParams];
    NSString *paramString = [dicOrder TY_urlParamsStringSignature:NO];
    NSString *urlString = @"";
    if ([[serviceIdentifier componentsSeparatedByString:@"?"] count] > 1) {
       urlString = [NSString stringWithFormat:@"%@%@", serviceIdentifier, methodName];
    } else {
       urlString = [NSString stringWithFormat:@"%@%@?", serviceIdentifier, methodName];
    }
    
    NSLog(@"NEW reqeust URL:%@", urlString);
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:nil error:NULL];
    request.timeoutInterval = kAIFNetworkingTimeoutSeconds;
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(NSString *)serviceIdentifier requestParams:(NSDictionary *)requestParams methodName:(NSString *)methodName
{
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:serviceIdentifier parameters:requestParams error:NULL];
    request.timeoutInterval = kAIFNetworkingTimeoutSeconds;
    return request;
}

-(NSDictionary *)commonParams
{
    NSMutableDictionary *dicCommonParams = [NSMutableDictionary dictionary];
    NSString *str = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    return dicCommonParams;
}

@end
