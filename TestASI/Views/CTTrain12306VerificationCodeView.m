//
//  CTTrain12306VerificationCodeView.m
//  TestCodeView
//
//  Created by 田东海 on 15/3/16.
//  Copyright (c) 2015年 com.dh. All rights reserved.
//

#import "CTTrain12306VerificationCodeView.h"

#define CodeImageWidth 25.f

@interface CodeImageView : UIImageView

- (instancetype)initWithCenterPoint:(CGPoint)centerPoint;

@end

@implementation CodeImageView

- (instancetype)initWithCenterPoint:(CGPoint)centerPoint
{
    CGRect frame = CGRectMake(centerPoint.x - CodeImageWidth/2, centerPoint.y - CodeImageWidth/2, CodeImageWidth, CodeImageWidth);
    if (self = [super initWithFrame:frame]) {
        self.image = [UIImage imageNamed:@"point"];
    }
    return self;
}

@end

@interface CTTrain12306VerificationCodeView ()

@property (strong, nonatomic) UIButton *refreshButton;
@property (strong, nonatomic) UIImageView *codeImageView;
@property (strong, nonatomic) NSMutableArray *imageViewArray;
/** 可以响应点击事件的rect */
@property (assign, nonatomic) CGRect tapEnableRect;
/** 图片的压缩比例 */
@property (assign, nonatomic) CGFloat scale;
/** y轴可以响应点击事件的起始值 */
@property (assign, nonatomic) CGFloat yTapStart;

- (void)tapAction:(UITapGestureRecognizer *)sender;

@end

@implementation CTTrain12306VerificationCodeView

- (instancetype)initWithCodeImageSize:(UIImage *)codeImg withOrigin:(CGPoint)origin andYStart:(CGFloat)y
{
    CGSize size = codeImg.size;
    CGFloat screenWidth = CGRectGetWidth([[UIScreen mainScreen]bounds]);
    
    CGFloat selfWidth = (screenWidth - origin.x*2);
    
    CGRect frame = CGRectMake(origin.x, origin.y, selfWidth, size.height/(size.width/selfWidth));
    
    if (self = [super initWithFrame:frame]) {
        self.imageViewArray = [NSMutableArray array];
        
        self.scale = size.width/selfWidth;
        
        self.yTapStart = y/self.scale;
        
        self.tapEnableRect = CGRectMake(0, self.yTapStart, selfWidth, CGRectGetHeight(frame)-self.yTapStart);
        
        self.codeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, selfWidth, size.height/self.scale)];
        self.codeImageView.image = codeImg;
        [self addSubview:self.codeImageView];
        
        self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat refreshBtnY = 0;
        CGFloat refreshBtnHeight = 25.f;
        if (y > 25.f) {
            refreshBtnY = (y - 25)/2.f;
        }else{
            refreshBtnHeight = y;
        }
        
        self.refreshButton.frame = CGRectMake(320 - 60, 1 , 60, 30);
        [self.refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [self.refreshButton setTitle:@"刷新" forState:UIControlStateHighlighted];
        [self.refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.refreshButton addTarget:self action:@selector(refreshCodeImageAction:) forControlEvents:UIControlEventTouchUpInside];
        self.refreshButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        self.refreshButton.backgroundColor = [UIColor greenColor];
        [self addSubview:self.refreshButton];
        
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)]];
    }
    
    return self;
}

//刷新图片的时候调用
- (void)updateImage:(UIImage *)codeImg
{
    [self updateImage:codeImg andYStart:30.f];
}

- (void)updateImage:(UIImage *)codeImg andYStart:(CGFloat)y
{
    CGSize size = codeImg.size;
    
    self.codeImageView.image = codeImg;
    
    [self cleanPointImageCodeView];//清除屏幕上的点
    
    if (self.scale == size.width/CGRectGetWidth(self.frame)) {
        //说明图片的尺寸是没有变的
        return;
    }
    
    self.scale = size.width/CGRectGetWidth(self.frame);
    self.yTapStart = y/self.scale;
    
    CGRect frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), size.height/self.scale);
    self.frame = frame;
    
    self.tapEnableRect = CGRectMake(0, self.yTapStart, CGRectGetWidth(self.frame), CGRectGetHeight(frame)-self.yTapStart);
    
    CGFloat refreshBtnY = 0;
    CGFloat refreshBtnHeight = 25.f;
    if (y > 25.f) {
        refreshBtnY = (y - 25)/2.f;
    }else{
        refreshBtnHeight = y;
    }
    
    self.refreshButton.frame = CGRectMake(CGRectGetWidth(self.frame)-60, refreshBtnY , 50, refreshBtnHeight);
    
}

- (void)tapAction:(UITapGestureRecognizer *)sender {
    CGPoint tapPoint = [sender locationInView:self.codeImageView];
//    tapPoint = CGPointMake(tapPoint.x*self.scale, (tapPoint.y - self.yTapStart)*self.scale);
    NSNumber *number = [NSNumber numberWithFloat:tapPoint.x];
    NSLog(@"tapPoint = %@,%f,%ld",NSStringFromCGPoint(tapPoint),floorf(tapPoint.x),number.integerValue);
    CGRect pointEnableRect = self.tapEnableRect;
    
    //12306上面的点最多21个
    if (self.imageViewArray.count == 21) {
        
        //如果是第22个点，需要判断这个点是否包含在code数组里面，
        [self.imageViewArray enumerateObjectsUsingBlock:^(CodeImageView *obj, NSUInteger idx, BOOL *stop) {
            if (CGRectContainsPoint(obj.frame, tapPoint)) {
                [obj removeFromSuperview];
                [self.imageViewArray removeObject:obj];
                *stop = YES;
            }
        }];
        
        return;
    }
    
    //先判断有没有点在验证码图片的区域里
    if (!CGRectContainsPoint(pointEnableRect, tapPoint))   return;
    
    __block BOOL isExistPoint = NO;
    //然后再遍历pointArray,判断是否点在已有点的区域里
    [self.imageViewArray enumerateObjectsUsingBlock:^(CodeImageView *obj, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint(obj.frame, tapPoint)) {
            [obj removeFromSuperview];
            [self.imageViewArray removeObject:obj];
            isExistPoint = YES;
            *stop = YES;
        }
    }];
    
    if (isExistPoint) return;
    //如果那个点没有在数组中
    CodeImageView *imgView = [[CodeImageView alloc]initWithCenterPoint:tapPoint];
    [self.codeImageView addSubview:imgView];
    
    [self.imageViewArray insertObject:imgView atIndex:0];
}

- (void)refreshCodeImageAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(codeViewRefreshImage:)]) {
        [self.delegate codeViewRefreshImage:self];
    }
}

/** 清楚图片上的点 */
- (void)cleanPointImageCodeView
{
    for (CodeImageView *imgView in self.imageViewArray) {
        [imgView removeFromSuperview];
    }
    
    [self.imageViewArray removeAllObjects];
}

- (NSArray *)getTappedPoint
{
    NSMutableArray *points = [NSMutableArray array];
    [self.imageViewArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        NSNumber *numberX = [NSNumber numberWithFloat:obj.center.x*self.scale];
        NSNumber *numberY = [NSNumber numberWithFloat:(obj.center.y - self.yTapStart)*self.scale];
        [points addObject:numberX];
        [points addObject:numberY];
    }];
    
    return points;
}

- (NSString *)fetchTapString {
    NSArray *randCode = [self getTappedPoint];
    NSMutableString *resultCode = [NSMutableString string];
    for (NSNumber *rang in randCode) {
        if (resultCode.length < 1) {
            [resultCode appendFormat:@"%@", rang];
        } else {
            [resultCode appendFormat:@",%@", rang];
        }
    }
    return resultCode;
}

@end
