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

@interface RootViewController ()
@property (nonatomic, strong)UIImageView *img;
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
    [[SampleRequestManager shareInsatance] eighthRequestForLogin];
    // Do any additional setup after loading the view.
}
- (void)click {
    _img.image = [[UIImage alloc] initWithContentsOfFile:@"/var/mobile/Applications/38A9446E-C82D-474E-86F2-9C44CFF1A343/Library/asi.png"];
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
