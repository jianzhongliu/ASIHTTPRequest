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

@property (nonatomic, copy) NSString *randKey;//jsKey
@property (nonatomic, copy) NSString *randValue;//jsValue
@property (nonatomic, copy) NSString *secretStr;//从查票中获取
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) NSString *globalRepeatSubmitToken;//从initdc中的HTML中获取
@property (nonatomic, strong) NSString *key_check_isChange;
@property (nonatomic, strong) NSString *leftTicketStr;

@property (nonatomic, strong) NSString *randJSKeyAgain;//js Key
@property (nonatomic, strong) NSString *code;//验证码
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
- (UIImage *)base64StringToImage:(NSString *) base64String
{
    NSData *data = nil;
    NSString *str = base64String;
    data = [NSData dataFromBase64String:str];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}
- (void)goBackToRoot {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    self.manager1 = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[UINavigationBar appearance] setBackgroundImage:menuBarImage forBarMetrics:UIBarMetricsDefault];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBackToRoot) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 80, 40)];
    [self.view addSubview:self.imageView];
    
    [self checkUserInfo];

}

- (void)checkUserInfo {
    self.manager1 = [[AFHTTPRequestOperationManager alloc] init];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    NSString *url = @"https://kyfw.12306.cn/otn/login/checkUser";
    NSDictionary *dicParam = @{@"_json_att":@""};
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    
    [self.manager1 POST:url parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[[responseObject objectForKey:@"data"] objectForKey:@"flag"] integerValue] >= 1) {
            [self checkHasNoComplitedOrder];
        } else {
            [self checkUserInfo];
            NSLog(@"not login");
        }
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
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
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
    NSString *url = @"https://kyfw.12306.cn/otn/lcxxcx/query?purpose_codes=ADULT&queryDate=2015-03-26&from_station=SHH&to_station=BJP";
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"成功后返回的票信息：%@", operation.responseString);
        [self queryLeftTicket];
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
//    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/leftTicket/init" forHTTPHeaderField:@"Referer"];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.responseString.length > 0) {
            NSArray *arrayOne = [operation.responseString componentsSeparatedByString:@"otn/dynamicJs/"];
            NSArray *arrayTwo = [[arrayOne objectAtIndex:1] componentsSeparatedByString:@"\""];
            [self dynamicJs:[arrayTwo objectAtIndex:0]];//可能是从checkuser那里拿，或者从登陆那里拿到
        }
        
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
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);

        if (operation.responseString.length > 0) {
            NSArray *tempKeyArray = [operation.responseString componentsSeparatedByString:@"key='"];
            self.randKey = [[[tempKeyArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
            
            [self getJSValueWithJSKey:self.randKey];
        } else {
            [self checkUserInfo];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
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
            self.randValue = value;
            [self leftTicketLog];
//            [self atLastLoginWithJSKeyValue:key value:value];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [operation start];
}
/*
 xx
 */
- (void)leftTicketLog {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/log?leftTicketDTO.train_date=2015-03-26&leftTicketDTO.from_station=SHH&leftTicketDTO.to_station=BJP&purpose_codes=ADULT";
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/leftTicket/init" forHTTPHeaderField:@"Referer"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [self inputOrder];
        NSLog(@"成功后返回的用户信息leftTicketLog：%@", operation.responseString);
        [self checkLeftTicket];
        
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
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/query?leftTicketDTO.train_date=2015-03-26&leftTicketDTO.from_station=SHH&leftTicketDTO.to_station=BJP&purpose_codes=ADULT";
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/leftTicket/init" forHTTPHeaderField:@"Referer"];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       id json = operation.responseString.JSONValue;
        NSDictionary *dicValue = (NSDictionary *)json;
//        NSLog(@"%@",dicValue);
        if ([[dicValue objectForKey:@"data"] count] > 0) {
            NSString *secretStr = [[[dicValue objectForKey:@"data"] objectAtIndex:0]objectForKey:@"secretStr"];
            NSLog(@"%@",[[dicValue objectForKey:@"data"] objectAtIndex:0]);
            self.secretStr = secretStr;
            [self submitOrderRequestWithsSecretStr:secretStr];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 判断用户是否可以访问预定确认画面
 */
- (void)submitOrderRequestWithsSecretStr:(NSString *) secretStr {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/leftTicket/submitOrderRequest";
    NSMutableDictionary *dicParam = [NSMutableDictionary dictionary];
    [dicParam setValue:self.randValue forKey:self.randKey];
    [dicParam setValue:@"undefined" forKey:@"myversion"];
    [dicParam setValue:@"2015-03-26" forKey:@"train_date"];
    [dicParam setValue:@"2015-03-26" forKey:@"back_train_date"];
    [dicParam setValue:@"ADULT" forKey:@"purpose_codes"];
    [dicParam setValue:@"dc" forKey:@"tour_flag"];//dc单程，fc返程
    [dicParam setValue:@"上海虹桥" forKey:@"query_from_station_name"];
    [dicParam setValue:@"北京南" forKey:@"query_to_station_name"];
    [dicParam setValue:[secretStr urlDecodedString] forKey:@"secretStr"];//下单令牌
    [dicParam setValue:@"1.1" forKey:@"undefined"];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
//    [self.manager1.requestSerializer setValue:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/leftTicket/init" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:url parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        id json = operation.responseString.JSONValue;
        NSDictionary *dicValue = (NSDictionary *)json;
        if ([[dicValue objectForKey:@"status"] integerValue] >= 1) {//可以下订单了
            [self initDc];
        } else {
            [self checkUserInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 预定确认页面,html得到js的key
 */
- (void)initDc {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = @"https://kyfw.12306.cn/otn/confirmPassenger/initDc";
    NSDictionary *dic = @{@"_json_att":@""};
    [self.manager1 POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject){
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        if (operation.responseString.length > 0) {
            NSArray *arrayOne = [operation.responseString componentsSeparatedByString:@"otn/dynamicJs/"];
            NSArray *arrayTwo = [[arrayOne objectAtIndex:1] componentsSeparatedByString:@"\""];
            self.randJSKeyAgain = [arrayTwo objectAtIndex:0];
//            [self dynamicJsAgain:[arrayTwo objectAtIndex:0]];//可能是从checkuser那里拿，或者从登陆那里拿到
            [self getCheckCode];
            NSArray *arrayTokenKey = [operation.responseString componentsSeparatedByString:@"globalRepeatSubmitToken = '"];
            NSArray *arrayTokenValue = [[arrayTokenKey objectAtIndex:1] componentsSeparatedByString:@"'"];
            self.globalRepeatSubmitToken = [arrayTokenValue objectAtIndex:0];
            
            NSArray *key_check_isChangeOne = [operation.responseString componentsSeparatedByString:@"key_check_isChange':'"];
            NSArray *key_check_isChangeTwo = [[key_check_isChangeOne objectAtIndex:1] componentsSeparatedByString:@"'"];
            self.key_check_isChange = [key_check_isChangeTwo objectAtIndex:0];
            
            NSArray *leftTicketStrOne = [operation.responseString componentsSeparatedByString:@"leftTicketStr':'"];
            NSArray *leftTicketStrTwo = [[leftTicketStrOne objectAtIndex:1] componentsSeparatedByString:@"'"];
            self.leftTicketStr = [leftTicketStrTwo objectAtIndex:0];
            
        } else {
            [self checkUserInfo];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


/**
 
 */
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
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 GET:@"https://kyfw.12306.cn/otn/passcodeNew/getPassCodeNew.do?module=login&rand=sjrand" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSData *data = [NSData dataWithData:responseObject];
        NSString *dataString = [data base64EncodedString];//用这个string去请求ctrip的自动打码服务
        [self autoCodeWithBase64String:dataString];
        self.imageView.image = [self base64StringToImage:dataString];
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
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [manager2 POST:@"http://m.ctrip.com/restapi/soa2/10103/json/GetCheckCodeFromCtrip" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *code = [dic objectForKey:@"CheckCode"];
            self.code = code;
            [self checkCodeValidateWithCode:code];
        }
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
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"header:%@", [[operation response] allHeaderFields]);
        //        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"result JSON: %@", responseObject);
        if ([[[responseObject objectForKey:@"data"] objectForKey:@"result"] integerValue] == 1) {
            [self dynamicJsAgain:self.randJSKeyAgain];
        } else {
            [self initDc];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 
 */
/**
 获取js
 */
- (void)dynamicJsAgain:(NSString *) jsName {
    
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"https://kyfw.12306.cn/otn/dynamicJs/%@", jsName];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"成功后返回的用户信息：%@", operation.responseString);
        
        if (operation.responseString.length > 0) {
            NSArray *tempKeyArray = [operation.responseString componentsSeparatedByString:@"key='"];
            self.randKey = [[[tempKeyArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
            
            [self getJSValueWithJSKeyAgain:self.randKey];
        } else {
            [self checkUserInfo];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//js加密算法得到value
- (void)getJSValueWithJSKeyAgain:(NSString *) key {
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
            self.randValue = value;
            [self checkOrderInfo:self.code];
            [self getQueueCount];
            [self confirmSingleForQueue];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"error: %@", operation.responseString);
        
    }];
    
    [operation start];
}
//检查订单
- (void)checkOrderInfo:(NSString *) code {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    NSMutableDictionary *dicParam = [NSMutableDictionary dictionary];
    [dicParam setValue:self.randValue forKey:self.randKey];
    [dicParam setValue:self.globalRepeatSubmitToken forKey:@"REPEAT_SUBMIT_TOKEN"];
    [dicParam setValue:@"" forKey:@"_json_att"];
    [dicParam setValue:@"000000000000000000000000000000" forKey:@"bed_level_order_num"];
    [dicParam setValue:@"" forKey:@"cancel_flag"];
    [dicParam setValue:@"陈坤,1,420117198612012879,1_" forKey:@"oldPassengerStr"];
    [dicParam setValue:@"O,0,1,陈坤,1,420117198612012879,,N" forKey:@"passengerTicketStr"];//第一个是座位类型，3表示卧铺，0表示硬座？
    [dicParam setValue:code forKey:@"randCode"];
    [dicParam setValue:@"dc" forKey:@"tour_flag"];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/confirmPassenger/checkOrderInfo" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"header:%@", [[operation response] allHeaderFields]);
        //        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"checkOrderInfo: %@", responseObject);
        if ([[[responseObject objectForKey:@"data"] objectForKey:@"submitStatus"] integerValue] == 1) {
            
        } else {
//            [self checkOrderInfo:code];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error:checkOrderInfo: %@", error);
    }];
}

//排队订单
- (void)getQueueCount {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    NSMutableDictionary *dicParam = [NSMutableDictionary dictionary];
//    [dicParam setValue:self.randValue forKey:self.randKey];
    [dicParam setValue:self.globalRepeatSubmitToken forKey:@"REPEAT_SUBMIT_TOKEN"];
    [dicParam setValue:@"" forKey:@"_json_att"];
    [dicParam setValue:@"AOH" forKey:@"fromStationTelecode"];
    [dicParam setValue:@"O055300232M0933000469174800012" forKey:@"leftTicket"];
    [dicParam setValue:@"00" forKey:@"purpose_codes"];
    [dicParam setValue:@"O" forKey:@"seatType"];//第一个是座位类型，3表示卧铺，0表示硬座？
    [dicParam setValue:@"G136" forKey:@"stationTrainCode"];
    [dicParam setValue:@"VNP" forKey:@"toStationTelecode"];
    [dicParam setValue:@"Sun Mar 15 2015 00:00:00 GMT+0800 (CST)" forKey:@"train_date"];
    [dicParam setValue:@"5l0000G13661" forKey:@"train_no"];
        [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
        [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/confirmPassenger/getQueueCount" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"header:%@", [[operation response] allHeaderFields]);
        //        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"result JSON:checkOrderInfo %@", responseObject);
//        if ([[[responseObject objectForKey:@"data"] objectForKey:@"submitStatus"] integerValue] == 1) {
//            
//        } else {
//            [self initDc];
//        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//下单
- (void)confirmSingleForQueue {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    NSMutableDictionary *dicParam = [NSMutableDictionary dictionary];
    //    [dicParam setValue:self.randValue forKey:self.randKey];
    [dicParam setValue:self.globalRepeatSubmitToken forKey:@"REPEAT_SUBMIT_TOKEN"];
    [dicParam setValue:@"" forKey:@"_json_att"];
    [dicParam setValue:self.key_check_isChange forKey:@"key_check_isChange"];
    [dicParam setValue:self.leftTicketStr forKey:@"leftTicketStr"];
    [dicParam setValue:@"陈坤,1,420117198612012879,1_" forKey:@"oldPassengerStr"];
    [dicParam setValue:@"O,0,1,陈坤,1,420117198612012879,,N" forKey:@"passengerTicketStr"];//第一个是座位类型，3表示卧铺，0表示硬座？
    [dicParam setValue:@"00" forKey:@"purpose_codes"];
    [dicParam setValue:self.code forKey:@"randCode"];
    [dicParam setValue:@"H1" forKey:@"train_location"];
        [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
        [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/confirmPassenger/initDc" forHTTPHeaderField:@"Referer"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/confirmPassenger/confirmSingleForQueue" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"header:%@", [[operation response] allHeaderFields]);
        //        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"result JSON:checkOrderInfo %@", responseObject);
        //        if ([[[responseObject objectForKey:@"data"] objectForKey:@"submitStatus"] integerValue] == 1) {
        //
        //        } else {
        //            [self initDc];
        //        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//https://kyfw.12306.cn/otn/confirmPassenger/confirmSingleForQueue
//Printing description of info->_parameters:
//{
//    "REPEAT_SUBMIT_TOKEN" = 6952e5e01d58c7f19376d75e47d5aabb;//从initDc返回的HTML中取
//    "_json_att" = "";
//    "key_check_isChange" = F54D21F459F986AB74986FF71C518F62583B0C1AD18EF78679186B9A;//从initDc返回的HTML中取
//    leftTicketStr = O055300232M0933000469174800012;//从initDc返回的HTML中取
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
