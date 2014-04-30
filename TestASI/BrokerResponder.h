//
//  BrokerResponder.h
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 4/29/14.
//  Copyright (c) 2014 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface BrokerResponder : NSObject

@property (nonatomic, strong) NSString *imgPath;
@property int statusCode;
@property int requestID;
@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) NSString *identify;
@end
