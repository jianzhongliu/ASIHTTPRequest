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

@interface AFNetworkingRootController ()<NSXMLParserDelegate>

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, copy) NSString *rangCode;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager1;
@property (nonatomic, copy) NSString *randUrl;//init服务请求，包含了一个请求js文件的randUrl，这个是获取js的url的一部分
@property (nonatomic, copy) NSString *randKey;//js中解析出来的一个key
@property (nonatomic, copy) NSString *randValue;//js中解析出来的一个Value


@end

@implementation AFNetworkingRootController
//生成一张毛玻璃图片
- (UIImage*)blur:(UIImage*)theImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:6.0f] forKey:@"inputRadius"];//模糊度
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return returnImage;
}
- (void)goBackToRoot {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 40, 30);
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBackToRoot) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 80, 40)];
    [self.view addSubview:self.image];
    [self getconnect];
//    //获取验证码
//    [self getCheckCode];
    
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
 
 */
- (void)getconnect {
    NSArray* cookieArr = [self getArrayFromCookie];
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    //    self.manager1.requestSerializer = [AFJSONResponseSerializer serializer];
    //AFCompoundResponseSerializer返回二进制
    //这里是AFImageResponseSerializer时response返回的是image
    //AFJSONResponseSerializer返回json
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    [self.manager1 GET:@"https://kyfw.12306.cn/otn/login/init" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        [self getCheckCode];
        NSLog(@"%@",responseObject);
        NSXMLParser *xml = [[NSXMLParser alloc] initWithData:responseObject];
        XMLDictionaryParser *dicParser = [XMLDictionaryParser sharedInstance];
        NSDictionary *dic = [dicParser dictionaryWithParser:xml];
        NSArray *arrayTEmp = [NSArray arrayWithArray:[[dic objectForKey:@"head"] objectForKey:@"script"]];
        NSDictionary *dicTemp = [NSDictionary dictionaryWithDictionary:[arrayTEmp lastObject]];
        self.randUrl = [dicTemp objectForKey:@"_src"];
        if (self.randUrl.length > 0) {
            [self getCheckCode];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
/**
 注意：
 1，Get请求
 2，response是个image/jpeg，需要制定responseSerializer
 3,allowInvalidCertificates = yes
 */
- (void)getCheckCode {
    NSArray* cookieArr = [self getArrayFromCookie];
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
        self.image.image = [self base64StringToImage:dataString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//自动打码
- (void)autoCodeWithBase64String:(NSString *) base64String {
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //    [manager1.requestSerializer setValue:@"image/jpeg;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    //    [manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    NSString *token = [[[@"@K0aY5,e" stringByAppendingString:base64String] MD5String] uppercaseString];
    NSDictionary *dicParam = @{@"channel":@"tieyou.ios", @"token":token, @"base64Code":base64String};
    
    [self.manager1 POST:@"http://m.ctrip.com/restapi/soa2/10103/json/GetCheckCodeFromCtrip" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString *code = [dic objectForKey:@"CheckCode"];
            self.rangCode = code;
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
    NSDictionary *dicParam = @{@"rand":@"sjrand", @"randCode":code, @"randCode_validate":@""};
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
//    [self.manager1.requestSerializer.mutableHTTPRequestHeaders setValue:stringCookie forKey:@"Cookie"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/passcodeNew/checkRandCodeAnsyn" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"header:%@", [[operation response] allHeaderFields]);
//        NSLog(@"header:%@", [[operation request] allHeaderFields]);
        NSLog(@"result JSON: %@", responseObject);
        if ([[[responseObject objectForKey:@"data"] objectForKey:@"result"] integerValue] == 1) {
            [self login0];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//获取js文件
- (void)login0{
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
    NSString *url = [NSString stringWithFormat:@"https://kyfw.12306.cn%@", self.randUrl];
    [self.manager1 GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"header:%@", operation.response.allHeaderFields);
//        NSLog(@"JSON: %@", responseObject);
//        NSXMLParser *xml = [[NSXMLParser alloc] initWithData:responseObject];
//        XMLDictionaryParser *dicParser = [XMLDictionaryParser sharedInstance];
//        NSDictionary *dic = [dicParser dictionaryWithParser:xml];
//        NSLog(@"%@", dic);
        
        //从js重分离出key和value
        NSData *doubi = responseObject;
        NSString *shabi =  [[NSString alloc] initWithData:doubi encoding:NSUTF8StringEncoding];
#warning TODO 得到登录时的随机参数
        NSArray *tempKeyArray = [shabi componentsSeparatedByString:@"key='"];
        self.randKey = [[[tempKeyArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
        
        NSArray *tempValueArray = [shabi componentsSeparatedByString:@"key='"];
        self.randValue = [[[tempValueArray objectAtIndex:1] componentsSeparatedByString:@"'"] objectAtIndex:0];
        
        [self login2];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger status = [[dic objectForKey:@"status"] integerValue];
            if (status == 1) {
                NSLog(@"登录成功");
            } else {
                //                [self login];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}
//登录
- (void)login2{
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
//    self.manager1.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //    [self.manager1.responseSerializer addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]]
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    
    NSDictionary *dicParam = @{@"randCode":self.rangCode, @"userDTO.password":@"a123456", @"loginUserDTO.user_name":@"antingniu", @"ODE0Mjkx":@"NDMyNzk4M2IwYmY1NzkwMQ==", @"myversion":@"undefined"};
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.manager1.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [self.manager1.requestSerializer setValue:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    [self.manager1.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [self.manager1.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn" forHTTPHeaderField:@"Origin"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/login/loginAysnSuggest" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"header:%@", operation.response.allHeaderFields);
        NSLog(@"JSON: %@", responseObject);

//        https://kyfw.12306.cn/otn/dynamicJs/lwluywt
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger status = [[dic objectForKey:@"status"] integerValue];
            if (status == 1) {
                NSLog(@"登录成功");
            } else {
                //                [self login];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//登录
- (void)login{
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager1.responseSerializer = [AFCompoundResponseSerializer serializer];
    self.manager1.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //    [self.manager1.responseSerializer addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]]
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    
    NSDictionary *dicParam = @{@"randCode":self.rangCode, @"userDTO.password":@"a123456", @"loginUserDTO.user_name":@"antingniu"};
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"text/html;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [self.manager1.requestSerializer setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [self.manager1.requestSerializer setValue:@"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    [self.manager1.requestSerializer setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [self.manager1.requestSerializer setValue:@"gzip, deflate" forHTTPHeaderField:@"Accept-Encoding"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn" forHTTPHeaderField:@"Origin"];
    [self.manager1 POST:@"https://kyfw.12306.cn/otn/login/userLogin" parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"header:%@", operation.response.allHeaderFields);
        NSLog(@"JSON: %@", responseObject);
        NSXMLParser *xml = [[NSXMLParser alloc] initWithData:responseObject];
        XMLDictionaryParser *dicParser = [XMLDictionaryParser sharedInstance];
        NSDictionary *dic = [dicParser dictionaryWithParser:xml];
        if (dic) {
            [self login0];
        }
        NSLog(@"%@", dic);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger status = [[dic objectForKey:@"status"] integerValue];
            if (status == 1) {
                NSLog(@"登录成功");
            } else {
                //                [self login];
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
