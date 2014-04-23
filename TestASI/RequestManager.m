//
//  RequestManager.m
//  TestASI
//
//  Created by jianzhongliu on 4/1/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import "RequestManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

typedef NS_ENUM (NSInteger , TAG){
    TAGTYPEName = 2,
    TAGTYPERESex = 3
    
};
@implementation RequestManager

+ (instancetype)shareReachability {
    static RequestManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[RequestManager alloc] init];
        }
    });
    return manager;
}

- (void)firstRequest:(NSString *)path {
    NSDictionary *dic = @{    @"app" : @"i-broker2",
                              @"cid" : @"-1",
                              @"cv" : @"3.3.2ver0421",
                              @"from" : @"mobile",
                              @"m" : @"iPhone%20Simulator",
                              @"macid" : @"86672bdcdc52b86d43cbe40a38eca10d",
                              @"o" : @"iPhone%20OS",
                              @"ostype2" : @"ios7",
                              @"pm" : @"A01",
                              @"qtime" : @"20140422180752",
                              @"udid2" : @"E4DC1717-F6AA-43D3-AFD3-0CB8F94DC7CB",
                              @"uuid" : @"86733EAF-A8B9-4CE4-A6C6-659C62C8F12C",
                              @"uuid2" : @"86733EAF-A8B9-4CE4-A6C6-659C62C8F12C",
                              @"v" : @"7.1"};
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"47370051ec1baa2a4d6a92c163460275", @"token", @"221439", @"brokerId",@"22", @"cityId", @"1", @"chatFlag", nil];

    NSMutableDictionary *headerDic = [NSMutableDictionary dictionary];
    [headerDic setValue:@"" forKey:@"sig"];
    [headerDic setValue:@"16ef94c3684a3b93626e5694affd167e" forKey:@"key"];
    [headerDic setValue:@"application/json" forKey:@"Accept"];
    [headerDic setValue:@"application/json" forKey:@"Content-Type"];
    [headerDic setValue:@"rcCobs2Q28k6E2Q4DT0/Pq8elHn8dA0rnx6Bd1qBn512HfjHjklE+kC+dq3Qu3fh0kTkLOCE3uUwSP+kAxKuek1sVwro1VVzmIeMBBsZS/aLbXcAdfp1IyH+UCJMRTb0IMEwPnVaZe/Gx0UgzU/wJM5oiz8SNh1KCHv4Jf32AU5aLVaRKDdcGzjZaXwV43kmZh8lF4SX1T35CFWWC7yqdxfEp9TEiMrcLOOchv7MFmze2AE1RE6orT0Ult08bvSwjRHk457EysVZYJWLQ8OHMg==" forKey:@"AuthToken"]; //add auth token
    
    [headerDic setValue:[self signRESTPostForRequestMethod:nil commParams:dic apiParams:params] forKey:@"sig"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *beforeEncode = [self implodeWithDictionary:params withSeparator:@"&" encode:NO];
    beforeEncode = [NSString stringWithFormat:@"&%@", beforeEncode];
    [beforeEncode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *apiSite = [NSString stringWithFormat:@"http://api.anjuke.com/mobile-ajk-broker"];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[apiSite stringByAppendingFormat:@"%@/%@?%@", @"/1.0", @"broker/getinfoandppc/", [self generateParametersWithDictionary:dic]]]];
    NSArray *keys = [headerDic allKeys];
    for (NSString *key in keys) {
        if ([[NSNull null] isEqual:[headerDic objectForKey:key]] || [@"" isEqualToString:[headerDic objectForKey:key]])
            continue;
        [request addRequestHeader:key value:[headerDic objectForKey:key]];
    }
    request.delegate = self;
    [request setPostBody:[NSMutableData dataWithData:jsonData]];
    request.timeOutSeconds = 30;
    request.tag = TAGTYPEName;
    request.shouldContinueWhenAppEntersBackground = YES;
    
    [request startAsynchronous];
}

- (NSString *)generateParametersWithDictionary:(NSDictionary *)params
{
    NSString *beforeEncode = [self implodeWithDictionary:params withSeparator:@"&" encode:NO];
    beforeEncode = [NSString stringWithFormat:@"&%@", beforeEncode];
    
    return [beforeEncode stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)signRESTPostForRequestMethod:(NSString *)methodName commParams:(NSDictionary *)commParams apiParams:(NSDictionary *)apiParams{

    
    NSString *part1 = @"/1.0/broker/getinfoandppc/";
    NSString *part2 = [self implodeWithDictionary:commParams withSeparator:@"&" encode:NO];
    NSString *part3 = [apiParams RTJSONRepresentation];
    NSString *part4 = @"4520776bd0c3bfd5";
    
    NSString *beforeSign = [NSString stringWithFormat:@"%@%@%@%@", part1, part2, part3, part4];

    return [beforeSign md5];
    
}

- (NSString *)implodeWithDictionary:(NSDictionary *)dic withSeparator:(NSString *)str encode:(BOOL)encode{
    
    //为了和andriod一直所以使用key=value后再排序
    
    NSMutableArray *keyValues = [NSMutableArray array];
    
    for (NSString *key in [dic allKeys]) {
        id value = [dic objectForKey:key];
        if (![[NSNull null] isEqual:value] && ![@"" isEqualToString:value]){
            if (encode) {
                value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)value,  NULL,  (CFStringRef)@"!*'();:@&;=+$,/?%#[]",  kCFStringEncodingUTF8));
            }
            NSString *temp = [NSString stringWithFormat:@"%@%@=%@", str, key, value];
            [keyValues addObject:temp];
        }
    }
    
    NSArray *newKeyValues = [keyValues sortedArrayUsingSelector:@selector(compare:)];
    NSString *temp = @"";
    for (NSString *value in newKeyValues) {
        temp = [NSString stringWithFormat:@"%@%@", temp, value];
    }
    if (temp.length>1) {
        temp = [temp substringFromIndex:1];
    }else{
        temp = temp;
    }
    return temp;
}
- (void)requestStarted:(ASIHTTPRequest *)request {
    dispatch_async(dispatch_get_main_queue(),^{
    
    
    });
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.tag == TAGTYPEName) {
        
        __autoreleasing NSError *error;
        NSDictionary *receiveDic = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
        NSLog(@"%@===%@", receiveDic, request.userInfo);
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {

}

@end
