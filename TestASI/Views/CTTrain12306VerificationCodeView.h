//
//  CTTrain12306VerificationCodeView.h
//  TestCodeView
//
//  Created by 田东海 on 15/3/16.
//  Copyright (c) 2015年 com.dh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTTrain12306VerificationCodeView;
@protocol CTTrain12306VerificationCodeViewDelegate <NSObject>

- (void)codeViewRefreshImage:(CTTrain12306VerificationCodeView *)codeView;

@end


@interface CTTrain12306VerificationCodeView : UIView

@property (weak, nonatomic) id<CTTrain12306VerificationCodeViewDelegate> delegate;

//初始化的时候调用
- (instancetype)initWithCodeImageSize:(UIImage *)codeImg withOrigin:(CGPoint)origin andYStart:(CGFloat)y;

//刷新图片的时候调用
- (void)updateImage:(UIImage *)codeImg;

//刷新图片的时候调用,y默认30
- (void)updateImage:(UIImage *)codeImg andYStart:(CGFloat)y;

- (NSArray *)getTappedPoint;

- (NSString *)fetchTapString;

@end
