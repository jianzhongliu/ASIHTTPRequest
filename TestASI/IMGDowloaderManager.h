//
//  IMGDowloaderManager.h
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 4/28/14.
//  Copyright (c) 2014 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMGDownloaderOperation.h"
#import "BrokerResponder.h"

@interface IMGDowloaderManager : NSObject <IMGDownloaderOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, copy) void(^successBlock)(BrokerResponder *);
@property (nonatomic, copy) void(^faildBlock)(BrokerResponder *);

- (void)cancelAllRequest;
/*
 参数：
 url ：图片地址
 identify：标识这个请求的唯一标识符，当请求很多时，通过判断传入的identify和responder的identify是否相等来区别是否是这个请求的结果
 block：successBlock在请求进行前会回调。在请求成功时也会调。failedBlock在请求失败时会调
 block体：参数response包括了identify，status，request等信息，通过判断status区别是不是成功，当status==1，startrequest；当status=2，requestsuccess；当statu=3，requestfailed
 结果：我们要的img就在当status==2时，在response的imagePath里面。
 */
- (void)dowloadIMGWithImgURL:(NSString *)url identify:(NSString *) identify successBlock:(void(^)(BrokerResponder *))successBlock fialedBlock:(void(^)(BrokerResponder *))failedBlock;

@end
