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
@property (nonatomic, copy) NSString *rangCode;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager1;

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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 80, 40)];
    [self.view addSubview:self.image];
    //获取验证码
    [self getCheckCode];
    
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
//        NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[operation.response allHeaderFields] forURL:operation.request.URL];
//        NSLog(@"JSON: %@", responseObject);
        NSData *data = [NSData dataWithData:responseObject];
        NSString *dataString = [data base64EncodedString];//用这个string去请求ctrip的自动打码服务
        [self autoCodeWithBase64String:dataString];
        self.image.image = [self base64StringToImage:dataString];
//        if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
//            UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//            visualEffectView.frame = self.image.bounds;
//            visualEffectView.alpha = 0.7;
//            [self.image addSubview:visualEffectView];
//        } else {
//            self.image.image = [self blur:[self base64StringToImage:dataString] ];
//        }
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
//        NSLog(@"JSON: %@", responseObject);
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
        [self login];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

//登录
- (void)login{
    self.manager1 = [AFHTTPRequestOperationManager manager];
    self.manager1.securityPolicy.allowInvalidCertificates = YES;
    self.manager1.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager1.responseSerializer = [AFJSONResponseSerializer serializer];
    NSArray* cookieArr = [self getArrayFromCookie];
    NSString *stringCookie = @"";
    stringCookie = [NSString stringWithFormat:@"JSESSIONID=%@; BIGipServerotn=%@; current_captcha_type=%@", [[cookieArr objectAtIndex:2] objectForKey:@"value"],[[cookieArr objectAtIndex:0] objectForKey:@"value"],[[cookieArr objectAtIndex:1] objectForKey:@"value"]];
    
    NSDictionary *dicParam = @{@"userName":@"antingniu", @"passWord":@"a123456", @"randCode":self.rangCode};
    NSString *urlString = [NSString stringWithFormat:@"https://kyfw.12306.cn/otn/login/loginAysnSuggest"];
    [self.manager1.requestSerializer setValue:stringCookie forHTTPHeaderField:@"Cookie"];
    [self.manager1.requestSerializer setValue:@"https://kyfw.12306.cn/otn/login/init" forHTTPHeaderField:@"Referer"];
    
    [self.manager1 POST:urlString parameters:dicParam success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"header:%@", operation.response.allHeaderFields);
        NSLog(@"JSON: %@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger status = [[dic objectForKey:@"status"] integerValue];
            if (status == 1) {
                NSLog(@"登录成功");
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
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
