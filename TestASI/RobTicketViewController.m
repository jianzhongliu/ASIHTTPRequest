//
//  RobTicketViewController.m
//  TestASI
//
//  Created by liujianzhong on 15/3/14.
//  Copyright (c) 2015年 anjuke. All rights reserved.
//

#import "RobTicketViewController.h"

@interface RobTicketViewController ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager1;

@end

@implementation RobTicketViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkUserInfo];

}

- (void)checkUserInfo {
    self.manager1 = [[AFHTTPRequestOperationManager alloc] init];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    NSString *url = @"https://kyfw.12306.cn/otn/login/checkUser";
    NSDictionary *dicParam = @{@"_json_att":@""};
    [self.manager1 POST:url parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self checkHasNoComplitedOrder];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
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
            [self queryTicketInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 查票
 */
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
        [self queryLeftTicket];
        //开始登陆，获取cookie的空请求
        //        [self connectToServer];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 查余票
 */
- (void)queryLeftTicket {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/init";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self dynamicJs:@"tempJs"];//可能是从checkuser那里拿，或者从登陆那里拿到
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 获取js
 */
- (void)dynamicJs:(NSString *) jsName {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"https://kyfw.12306.cn/otn/dynamicJs/%@", jsName];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self leftTicketLog];
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        //        [self login0WithRandJS:@"ddd"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/*
 xx
 */
- (void)leftTicketLog {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/log?leftTicketDTO.train_date=2015-03-15&leftTicketDTO.from_station=SHH&leftTicketDTO.to_station=BJP&purpose_codes=ADULT";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self inputOrder];
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        //        [self login0WithRandJS:@"ddd"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/**
 再次查询余票
 */
- (void)checkLeftTicket {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/query?leftTicketDTO.train_date=2015-03-15&leftTicketDTO.from_station=SHH&leftTicketDTO.to_station=BJP&purpose_codes=ADULT";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self submitOrderRequest];
        //        [self login0WithRandJS:@"ddd"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)submitOrderRequest {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest";
    NSDictionary *dic = @{@"__request__params__":@""};
    //参数：    "__request__params__" = "MjgyOTQ3=YTdkNzYxMTNkMjc0YzY5OQ%3D%3D&myversion=undefined&train_date=2015-03-15&back_train_date=2015-03-15&purpose_codes=ADULT&tour_flag=dc&query_from_station_name=%E4%B8%8A%E6%B5%B7%E8%99%B9%E6%A1%A5&query_to_station_name=%E5%8C%97%E4%BA%AC%E5%8D%97&secretStr=MjAxNS0wMy0xNSMwMCNHNCMwNDo0OCMxNDowMCM1bDAwMDAwMEc0MzAjQU9II1ZOUCMxODo0OCPkuIrmtbfombnmoaUj5YyX5Lqs5Y2XIzAxIzAzI08wNTUzMDAwMDBNMDkzMzAwMDAxOTE3NDgwMDAwNCNIMSMxNDI2MzE4NjgxNjEzIzI5RTc4RUJGMkM5RERENEI0NTE4NzFFRTM5Qzg1NUVFNTlFQTE5QkJEODQwMUEwQzM3REFCMzY2&undefined=";
/*    <__NSArrayM 0x15dbd440>(
    {
        key = MjgyOTQ3;
        value = "YTdkNzYxMTNkMjc0YzY5OQ==";
    },
    {
        key = myversion;
        value = undefined;
    },
    {
        key = "train_date";
        value = "2015-03-15";
    },
    {
        key = "back_train_date";
        value = "2015-03-15";
    },
    {
        key = "purpose_codes";
        value = ADULT;
    },
    {
        key = "tour_flag";
        value = dc;
    },
    {
        key = "query_from_station_name";
        value = "\U4e0a\U6d77\U8679\U6865";
    },
    {
        key = "query_to_station_name";
        value = "\U5317\U4eac\U5357";
    },
    {
        key = secretStr;
        value = MjAxNS0wMy0xNSMwMCNHNCMwNDo0OCMxNDowMCM1bDAwMDAwMEc0MzAjQU9II1ZOUCMxODo0OCPkuIrmtbfombnmoaUj5YyX5Lqs5Y2XIzAxIzAzI08wNTUzMDAwMDBNMDkzMzAwMDAxOTE3NDgwMDAwNCNIMSMxNDI2MzE4NjgxNjEzIzI5RTc4RUJGMkM5RERENEI0NTE4NzFFRTM5Qzg1NUVFNTlFQTE5QkJEODQwMUEwQzM3REFCMzY2;
    },
    {
        key = undefined;
        value = "";
    }
*/
    [self.manager1 POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        if ([[responseObject objectForKey:@"status"] integerValue] >= 1) {//没有未完成订单
            [self initDc];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)initDc {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/confirmPassenger/initDc";
    NSDictionary *dic = @{@"_json_att":@""};
    [self.manager1 POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        if ([[responseObject objectForKey:@"status"] integerValue] >= 1) {//没有未完成订单
            [self getCheckCode];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)getCheckCode {
//    NSArray* cookieArr = [self getArrayFromCookie];
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    //AFCompoundResponseSerializer返回二进制
    //这里是AFImageResponseSerializer时response返回的是image
    //AFJSONResponseSerializer返回json
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    //    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];//会自动加上
    //    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    [self.manager1 GET:@"https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew.do?module=login&rand=sjrand" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = [NSData dataWithData:responseObject];
        NSString *dataString = [data base64EncodedString];//用这个string去请求ctrip的自动打码服务
        [self autoCodeWithBase64String:dataString];
//        self.image.image = [self base64StringToImage:dataString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//自动打码
- (void)autoCodeWithBase64String:(NSString *) base64String {
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    manager2.securityPolicy.allowInvalidCertificates = YES;
    manager2.requestSerializer = [AFJSONRequestSerializer serializer];
    manager2.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    NSString *token = [[[@"@K0aY5,e" stringByAppendingString:base64String] MD5String] uppercaseString];
    NSDictionary *dicParam = @{@"channel":@"tieyou.ios", @"token":token, @"base64Code":base64String};
    [manager2 POST:@"http://m.ctrip.com/restapi/soa2/10103/json/GetCheckCodeFromCtrip" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *code = [dic objectForKey:@"CheckCode"];
//            self.rangCode = code;
            [self dynamicJsAgin:@"jsName"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 获取js
 */
- (void)dynamicJsAgin:(NSString *) jsName {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"https://kyfw.12306.cn/otn/dynamicJs/%@", jsName];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self leftTicketLog];
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        //        [self login0WithRandJS:@"ddd"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//验证验证码正确与否
- (void)checkCodeValidateWithCode:(NSString *) code {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    NSDictionary
    *dicParam = @{@"rand":@"sjrand", @"randCode":code, @"randCode_validate":@""};
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"header:%@", [[operation response] allHeaderFields]);
        //        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"result JSON: %@", responseObject);
        if ([[[responseObject objectForKey:@"data"] objectForKey:@"result"] integerValue] == 1) {
            [self getPassCode_New];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
- (void)getPassCode_New {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew?module=passenger&rand=randp&1426319400";
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self autoCodeWithBase64StringAgain:@"base64String"];
//        [self login0WithRandJS:@"ddd"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)autoCodeWithBase64StringAgain:(NSString *) base64String {
    AFHTTPRequestOperationManager *manager2 = [AFHTTPRequestOperationManager manager];
    manager2.securityPolicy.allowInvalidCertificates = YES;
    manager2.requestSerializer = [AFJSONRequestSerializer serializer];
    manager2.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    NSString *token = [[[@"@K0aY5,e" stringByAppendingString:base64String] MD5String] uppercaseString];
    NSDictionary *dicParam = @{@"channel":@"tieyou.ios", @"token":token, @"base64Code":base64String};
    [manager2 POST:@"http://m.ctrip.com/restapi/soa2/10103/json/GetCheckCodeFromCtrip" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *code = [dic objectForKey:@"CheckCode"];
            //            self.rangCode = code;
            [self dynamicJsAgin:@"jsName"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//https://kyfw.12306.cn/otn/confirmPassenger/checkOrderInfo
//{
//    MzgzMzU1 = "N2QxODg2N2Q2MTcxZWI0Yw==";
//    "REPEAT_SUBMIT_TOKEN" = 6952e5e01d58c7f19376d75e47d5aabb;
//    "_json_att" = "";
//    "bed_level_order_num" = 000000000000000000000000000000;
//    "cancel_flag" = 2;
//    oldPassengerStr = "\U9648\U5764,1,420117198612012879,1_";
//    passengerTicketStr = "O,0,1,\U9648\U5764,1,420117198612012879,,N";
//    randCode = k9zw;
//    "tour_flag" = dc;
//}

//https://kyfw.12306.cn/otn/confirmPassenger/getQueueCount
//{
//    "REPEAT_SUBMIT_TOKEN" = 6952e5e01d58c7f19376d75e47d5aabb;
//    "_json_att" = "";
//    fromStationTelecode = AOH;
//    leftTicket = O055300232M0933000469174800012;
//    "purpose_codes" = 00;
//    seatType = O;
//    stationTrainCode = G136;
//    toStationTelecode = VNP;
//    "train_date" = "Sun Mar 15 2015 00:00:00 GMT+0800 (CST)";
//    "train_no" = 5l0000G13661;
//}

//https://kyfw.12306.cn/otn/confirmPassenger/confirmSingleForQueue
//Printing description of info->_parameters:
//{
//    "REPEAT_SUBMIT_TOKEN" = 6952e5e01d58c7f19376d75e47d5aabb;
//    "_json_att" = "";
//    "key_check_isChange" = F54D21F459F986AB74986FF71C518F62583B0C1AD18EF78679186B9A;
//    leftTicketStr = O055300232M0933000469174800012;
//    oldPassengerStr = "\U9648\U5764,1,420117198612012879,1_";
//    passengerTicketStr = "O,0,1,\U9648\U5764,1,420117198612012879,,N";
//    "purpose_codes" = 00;
//    randCode = k9zw;
//    "train_location" = H1;
//}

//https://kyfw.12306.cn/otn/confirmPassenger/queryOrderWaitTime?random=1426320180768&tourFlag=dc&_json_att=&REPEAT_SUBMIT_TOKEN=6952e5e01d58c7f19376d75e47d5aabb

//https://kyfw.12306.cn/otn/confirmPassenger/resultOrderForDcQueue
//Printing description of info->_parameters:
//{
//    "REPEAT_SUBMIT_TOKEN" = 6952e5e01d58c7f19376d75e47d5aabb;
//    "_json_att" = "";
//    "orderSequence_no" = E043033936;
//}

//https://kyfw.12306.cn/otn/queryOrder/queryMyOrderNoComplete
//Printing description of info->_parameters:
//{
//    "_json_att" = "";
//}
@end
