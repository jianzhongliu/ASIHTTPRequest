//
//  QueryTicketViewController.m
//  TestASI
//
//  Created by liujianzhong on 15/3/13.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "QueryTicketViewController.h"
#import "TYAPIProxy.h"

@interface QueryTicketViewController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager1;

@end

@implementation QueryTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self queryTicketInfo];

}




- (void)queryTicketInfo {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/lcxxcx/query?purpose_codes=ADULT&queryDate=2015-03-14&from_station=SHH&to_station=BJP";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self goBackToRoot];//登陆成功后返回
        //        NSXMLParser *xml = [[NSXMLParser alloc] initWithData:responseObject];
        
        //        XMLDictionaryParser *dicParser = [XMLDictionaryParser sharedInstance];
        //        NSDictionary *dic = [dicParser dictionaryWithParser:xml];
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        [self queryStationCenterStation];
        //开始登陆，获取cookie的空请求
//        [self connectToServer];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)queryStationCenterStation {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/czxx/queryByTrainNo?train_no=5l0000G10641&from_station_telecode=AOH&to_station_telecode=VNP&depart_date=2015-03-14";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        [self checkHasNoComplitedOrder];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//检查是否有未完成订单
- (void)checkHasNoComplitedOrder {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/queryOrder/queryMyOrderNoComplete";
    NSDictionary *dic = @{@"_json_att":@""};
    [self.manager1 POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        if ([[responseObject objectForKey:@"status"] integerValue] >= 1) {//没有未完成订单
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//https://kyfw.12306.cn/otn/leftTicket/init

- (void)queryLeftTicket {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/init";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self inputOrder];
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
//        [self login0WithRandJS:@"ddd"];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//获取js文件
- (void)login0WithRandJS:(NSString *) randJS{
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager1.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.manager1.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/javascript"];
    //    [self.manager1.responseSerializer addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]]
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    NSString *url = [NSString stringWithFormat:@"https://kyfw.12306.cn%@", randJS];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //从js重分离出key和value
        NSData *doubi = responseObject;
        NSString *shabi =  [[NSString alloc] initWithData:doubi encoding:NSUTF8StringEncoding];
#warning TODO 得到登录时的随机参数
        NSArray *tempKeyArray = [shabi componentsSeparatedByString:@"key='"];
//        self.randKey = [[[tempKeyArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
        
        NSArray *tempValueArray = [shabi componentsSeparatedByString:@"key='"];
//        self.randValue = [[[tempValueArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
        
//        [self getJSValueWithJSKey:self.randValue];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//http://localhost:8080/StudyForStudent/REST/mysfuck/get12306ValueByKey/Nzc0NTg4÷
//js加密算法得到value
- (void)getJSValueWithJSKey:(NSString *) key {
    NSString *urlString1 = [NSString stringWithFormat:@"http://localhost:8080/StudyForStudent/REST/mysfuck/get12306ValueByKey/%@",key];
    
    NSURL *url = [NSURL URLWithString:urlString1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"operation hasAcceptableStatusCode: %ld", (long)[operation.response statusCode]);
        NSLog(@"得到js的value: %@ ", operation.responseString);
        NSString *value = operation.responseString;
        if (value.length > 0 && value.length < 50) {
//            [self atLastLoginWithJSKeyValue:key value:value];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [operation start];
}

- (void)inputOrder {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/log?leftTicketDTO.train_date=2015-03-14&leftTicketDTO.from_station=AOH&leftTicketDTO.to_station=VNP&purpose_codes=ADULT";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//https://kyfw.12306.cn/otn/leftTicket/query?leftTicketDTO.train_date=2015-03-14&leftTicketDTO.from_station=AOH&leftTicketDTO.to_station=VNP&purpose_codes=ADULT

//https://kyfw.12306.cn/otn/login/checkUser
//下单服务和参数post请求
//https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest
//    "__request__params__" = "NTQ4Mzcx=MTY2MDdhYTdiNGM4YzFmZQ%3D%3D&myversion=undefined&train_date=2015-03-14&back_train_date=2015-03-14&purpose_codes=ADULT&tour_flag=dc&query_from_station_name=%E4%B8%8A%E6%B5%B7%E8%99%B9%E6%A1%A5&query_to_station_name=%E5%8C%97%E4%BA%AC%E5%8D%97&secretStr=MjAxNS0wMy0xNCMwMCNHMTA0IzA1OjMyIzA3OjEwIzVsMDAwMEcxMDQ0MCNBT0gjVk5QIzEyOjQyI%2BS4iua1t%2BiZueahpSPljJfkuqzljZcjMDEjMDkjTzA1NTMwMDA3OE0wOTMzMDAwOTY5MTc0ODAwMDIyI0gxIzE0MjYyNDk4ODcyOTAjQjczOTA4MzhFNDNBMzUwRDNFNzJCODQ1QUVDNDg1Q0Q1QTUyNEUyNDU5NDU0NTZGN0VEMkI1RUE%3D&undefined=";
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
