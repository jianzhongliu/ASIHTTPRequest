//
//  AFNetworkingRootController.m
//  TestASI
//
//  Created by jianzhong on 27/2/15.
//  Copyright (c) 2015 anjuke. All rights reserved.
//

#import "AFNetworkingRootController.h"
#import "TYAPIProxy.h"
#import "UIImageView+AFNetworking.h"
#import "TYRequestGenerator.h"

@interface AFNetworkingRootController ()
@property (nonatomic, strong) UIImageView *image;
@end

@implementation AFNetworkingRootController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 80, 40)];
    [self.view addSubview:self.image];
    //获取验证码
    [self getCheckCode];
    

    
/////////////////////////////////////////////////////////////查票,//////////////////////////////////////////////////////
//    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:getPassCodeNew]];
//    [[client securityPolicy] setAllowInvalidCertificates:YES];
//    [client GET:@"https://kyfw.12306.cn/otn/leftTicket/query?leftTicketDTO.train_date=2015-04-06&leftTicketDTO.from_station=SZQ&leftTicketDTO.to_station=BHQ&purpose_codes=ADULT" parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"leftTicket===Error: %@", responseObject);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"leftTicket===Error: %@", error);
//        [self dismissModalViewControllerAnimated:YES];
//    }];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
///////////////////////////////////////////////////////////////查票,//////////////////////////////////////////////////////
//    AFHTTPSessionManager * client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:getPassCodeNew]];
//    [[client securityPolicy] setAllowInvalidCertificates:YES];
//    [client GET:@"https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew.do?module=login&rand=sjrand&1425090475" parameters:@"" success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"getPassCodeNew.do===JSON: %@", responseObject);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"getPassCodeNew.do===Error: %@", error);
//        [self dismissModalViewControllerAnimated:YES];
//    }];
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
}

/**
 注意：
 1，Get请求
 2，response是个image/jpeg，需要制定responseSerializer
 3,allowInvalidCertificates = yes
 */
- (void)getCheckCode {
    NSArray* cookieArr = [self getArrayFromCookie];
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.securityPolicy.allowInvalidCertificates = YES;
    manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    //AFCompoundResponseSerializer返回二进制
    //这里是AFImageResponseSerializer时response返回的是image
    //AFJSONResponseSerializer返回json
    manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
//    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];//会自动加上
//    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    [manager1 GET:@"https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew.do?module=login&rand=sjrand" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSData *data = [NSData dataWithData:responseObject];
        NSString *dataString = [data base64EncodedString];//用这个string去请求ctrip的自动打码服务
        [self autoCodeWithBase64String:dataString];
        self.image.image = [self base64StringToImage:dataString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//自动打码
- (void)autoCodeWithBase64String:(NSString *) base64String {
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.securityPolicy.allowInvalidCertificates = YES;
    manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    NSString *token = [[[@"@K0aY5,e" stringByAppendingString:base64String] MD5String] uppercaseString];
    NSDictionary *dicParam = @{@"channel":@"tieyou.ios", @"token":token, @"base64Code":base64String};
    
    [manager1 POST:@"http://m.ctrip.com/restapi/soa2/10103/json/GetCheckCodeFromCtrip" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *code = [dic objectForKey:@"CheckCode"];
            [self checkCodeValidateWithCode:code];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//验证验证码正确与否
- (void)checkCodeValidateWithCode:(NSString *) code {
    AFHTTPRequestOperationManager *manager1 = [AFHTTPRequestOperationManager manager];
    manager1.securityPolicy.allowInvalidCertificates = YES;
    manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    manager1.responseSerializer = [AFJSONResponseSerializer serializer];

    NSDictionary *dicParam = @{@"rand":@"sjrand", @"randCode":code, @"randCode_validate":@""};

    [manager1 POST:@"https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *status = [[dic objectForKey:@"data"] objectForKey:@"result"];
            if ([status isEqualToString:@"1"]) {
                NSLog(@"认证成功");
            } else {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 把base64的图片数据转化成UIImage
 params:
 base64String:base64的图片数据
 */
- (UIImage *)base64StringToImage:(NSString *) base64String
{
    NSData *data = nil;
    NSString *str = base64String;
    data = [NSData dataFromBase64String:str];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

- (NSMutableArray*)getArrayFromCookie
{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableArray* mutarr = [[NSMutableArray alloc] init];
    for (NSHTTPCookie* cook in [cookieJar cookies]) {
        if ([@"kyfw.12306.cn|mobile.12306.cn" rangeOfString:cook.domain].location != NSNotFound) {
            NSMutableDictionary* mutDic = [[NSMutableDictionary alloc] init];
            [mutDic setObject:cook.name forKey:@"name"];
            [mutDic setObject:cook.value forKey:@"value"];
            [mutDic setObject:cook.domain forKey:@"domain"];
            [mutarr addObject:mutDic];
        }
    }
    return mutarr;
}
@end
