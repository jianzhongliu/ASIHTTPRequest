//
//  TYAPIProxy.h
//  ticket99
//
//  Created by jianzhong on 29/1/15.
//  Copyright (c) 2015 xuzhq. All rights reserved.
//

/**
 用法：
1， //拼接请求参数
 NSDictionary *param = [NSDictionary dictionary];
2，调用Proxy发送服务
 NSInteger requestID = [[TYAPIProxy shareProxy] callGETWithParams:param identify:ApiArk methodName:@"trainTicketdetail" successCallBack:^(TYURLResponse *response) {
3， //成功回调处理
 NSLog(@"%@",response.contentString);
 } faildCallBack:^(TYURLResponse *response) {
4， //失败回调处理
 }];
5， //取消上面的服务
 [[TYAPIProxy shareProxy] cancelRequestByRequestID:requestID];
6， 取消所有TYAPIProxy的服务
 [[TYAPIProxy shareProxy] cancelAllRequest];
 */

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "TYURLResponse.h"

typedef void (^callBackBlock) (TYURLResponse *response);

@interface TYAPIProxy : NSObject

//存放所有的服务请求ID
@property (nonatomic, strong) NSMutableDictionary *mapRequestList;
//请求ID（不重复）
@property (nonatomic, strong) NSNumber *requestID;
/**
 请求服务的nameger，用来发送服务，和接受反回
 */
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;

+ (instancetype)shareProxy;

/**
 GET请求
 参数：
 params：服务所需要的参数，不包括公共参数和签名参数
 identify:服务的baseURL，定义在TYconfig.h中
 methodName:请求的方法名，注意：这个参数是baseURL和?之间的部分，可能是"requestUserName"，也可能是"10086/train/tieyou/getTrainList"
 successCallBack:成功回调
 faildCallBack：失败回调
 */
- (NSInteger)callGETWithParams:(NSDictionary *)params identify:(NSString *)identify methodName:(NSString *)methodName successCallBack:(callBackBlock) success faildCallBack:(callBackBlock) fail;

/**
POST请求
 参数：
 params：服务所需要的参数，不包括公共参数和签名参数
 identify:服务的baseURL，定义在TYconfig.h中
 methodName:请求的方法名，注意：这个参数是baseURL和?之间的部分，可能是"requestUserName"，也可能是"10086/train/tieyou/getTrainList"
 successCallBack:成功回调
 faildCallBack：失败回调
 */
- (NSInteger)callPOSTWithParams:(NSDictionary *)params identify:(NSString *)identify method:(NSString *)method successCallBack:(callBackBlock) success faildCallBack:(callBackBlock)fail;

/**
 取消指定ID的请求
 */
- (void)cancelRequestByRequestID:(NSInteger) identify;

/**
 取消所有的服务请求
 */
- (void)cancelAllRequest;
@end
