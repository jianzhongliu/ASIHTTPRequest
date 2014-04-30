//
//  IMGDownloaderOperation.h
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 4/28/14.
//  Copyright (c) 2014 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "BrokerResponder.h"

@protocol IMGDownloaderOperationDelegate <NSObject>

@optional
- (void)requestStarted:(ASIHTTPRequest *)request;
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)requestRedirected:(ASIHTTPRequest *)request;

@end

@interface IMGDownloaderOperation : NSOperation <ASIHTTPRequestDelegate>

@property (strong) NSRecursiveLock *cancelLock;
@property (nonatomic, strong) ASIHTTPRequest *networkRequest;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *requestString;
@property (nonatomic, strong) NSURL *requestUrl;
@property (nonatomic, assign) id<IMGDownloaderOperationDelegate> delegate;
@property int requestID;
@property (nonatomic, strong) NSString *identify;
@end
