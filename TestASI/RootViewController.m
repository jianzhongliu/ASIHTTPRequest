//
//  RootViewController.m
//  TestASI
//
//  Created by jianzhongliu on 4/1/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import "RootViewController.h"
#import "ReachabilityManager.h"
#import "RequestManager.h"
#import "SampleRequestManager.h"
#import "IMGDowloaderManager.h"

@interface RootViewController ()
@property (nonatomic, strong)UIImageView *img;
@property (nonatomic, strong)IMGDowloaderManager *downloader;
@property (nonatomic, strong)NSString *identify;
@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IMGDowloaderManager *)downloader {
    if (_downloader == nil) {
        _downloader = [[IMGDowloaderManager alloc] init];
    }
    return _downloader;
}

- (NSString *)identify {
//    static NSString *ident = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (ident == nil) {
            CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
            CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
            NSString *uuidString = [NSString stringWithString:(NSString*)CFBridgingRelease(strRef)];
//            ident = uuidString;
//        }
//    });
    return uuidString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        NSLog(@"%@",NSHomeDirectory());
//    [[RequestManager shareReachability] firstRequest:nil];
    UIProgressView *progessView = [[UIProgressView alloc] init];
    progessView.frame = CGRectMake(0, 100, 100, 300);
    progessView.progress  = 0.1;

    _img = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_img];
    
    UIButton *but = [UIButton buttonWithType:UIButtonTypeContactAdd];
    but.frame = CGRectMake(0, 100, 100, 50);
    [but addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:but];
    
    [self.view addSubview:progessView];
    [[SampleRequestManager shareInsatance] forthRequestForRequestQueue];
    // Do any additional setup after loading the view.
}

- (void)click {
    _img.image = nil;
//    [self.downloader cancelAllRequest];
    [self.downloader dowloadIMGWithImgURL:@"http://pic1.ajkimg.com/m/61a8745658b95a0f2c166f25d40fb70b/852x1136.jpg" identify:self.identify successBlock:^(BrokerResponder *response) {
        if (response.statusCode == 2) {
            _img.image = [[UIImage alloc] initWithContentsOfFile:response.imgPath];
        }
    } fialedBlock:^(BrokerResponder *response) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
