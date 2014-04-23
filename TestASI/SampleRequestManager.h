//
//  SampleRequestManager.h
//  TestASI
//
//  Created by jianzhongliu on 4/23/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASI/ASIHTTPRequest.h"

@interface SampleRequestManager : NSObject <ASIHTTPRequestDelegate, ASIProgressDelegate>

+(instancetype)shareInsatance;
- (void)firstRequestForSynchronous;
- (void)secondRequestForAsynchronous;
- (void)thirdRequestForBlockRequest;
- (void)forthRequestForRequestQueue;
- (void)fifthRequestForPostData;
- (void)sixthRequestForDownloadFileSource;
- (void)seventhRequestForDownloadIMGProgress:(UIProgressView *) myProgressIndicator;
- (void)eighthRequestForLogin;

@end
