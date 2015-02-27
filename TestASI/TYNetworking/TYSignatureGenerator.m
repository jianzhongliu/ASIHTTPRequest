//
//  TYSignatureGenerator.m
//  ticket99
//
//  Created by jianzhong on 29/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

#import "TYSignatureGenerator.h"
#import "NSDictionary+TYAFNetworking.h"

@implementation TYSignatureGenerator
/**
 加密字符串，用于签名
 签名时把参数拼接成字符串，传到这个方法加密，返回的就是签名
 */
+ (NSString *)signGETRestfulRequestWithSignParams:(NSString *) signature{
    NSString *sign = @"";
    sign = @"";
    return sign;
}

+ (NSDictionary *)compomentParamsAndOrder:(NSDictionary *) originParam {
    NSMutableDictionary *dictionaryResult = [NSMutableDictionary dictionary];
    NSMutableDictionary *dictionarySign = [NSMutableDictionary dictionaryWithDictionary:originParam];
    NSString *str = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    [dictionarySign setObject:str forKey:@"reqtime"];
    [dictionarySign setObject:[TYSignatureGenerator getAccessToken] forKey:@"token"];
    NSMutableArray *keys = [[NSMutableArray alloc]initWithCapacity:5];
    [keys addObjectsFromArray:[dictionarySign allKeys]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    [keys  sortUsingDescriptors:sortDescriptors];
    for(NSString* key in keys){
        NSString *val = [dictionarySign objectForKey:key];
        [dictionaryResult setValue:val forKey:key];
    }
    return dictionaryResult;
}

+ (NSString *)getAccessToken {

    return @"";
}

+ (NSString *)paramStringWithDictionary:(NSDictionary *) dicSign {
    NSDictionary *dicParam = [TYSignatureGenerator compomentParamsAndOrder:dicSign];
    NSMutableString *signature  = [NSMutableString string];
    NSArray *keys = [dicParam allKeys];
    for(NSString* key in keys){
        NSString *val = [dicSign objectForKey:key];
        if ([signature length] <= 0) {
            //第一个参数
        }else{
            [signature appendString:@"&"];
        }
        [signature appendFormat:@"%@=%@", key, val];
    }
    return signature;
}

@end
