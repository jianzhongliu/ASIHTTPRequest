//
//  IMGDownloaderOperation.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 4/28/14.
//  Copyright (c) 2014 Wu sicong. All rights reserved.
//

#import "IMGDownloaderOperation.h"

@implementation IMGDownloaderOperation

- (id)init
{
    self = [super init];
    if (self) {
        self.cancelLock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

- (void)start
{
    [self.cancelLock lock];
    if (![self isCancelled]) {
        [self main];
    }
    [self.cancelLock unlock];
}

- (void)main
{
    if (!self.isCancelled) {
        NSURL *url = [NSURL URLWithString:self.requestString];
        self.networkRequest = [ASIHTTPRequest requestWithURL:url];
        //当request完成时，整个文件会被移动到这里
        [self.networkRequest setDownloadDestinationPath:self.filePath];
        //这个文件已经被下载了一部分
        [self.networkRequest setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@.download", self.filePath]];
        [self.networkRequest setAllowResumeForFileDownloads:YES];//yes表示支持断点续传
        self.networkRequest.delegate = self;
        [self.networkRequest startAsynchronous];
    }
}

- (void)cancel
{
    [self.cancelLock lock];
    [self.networkRequest cancel];
    self.delegate = nil;
    [self.cancelLock unlock];
    [super cancel];
}

#pragma mark -- ASIHttpRequestDelegate
- (void)requestStarted:(ASIHTTPRequest *)request{
    BrokerResponder *responder = [[BrokerResponder alloc] init];
    responder.requestID = [self.networkRequest.requestID integerValue];
    responder.statusCode = 1;
//    responder.imgPath = self.filePath;
    responder.request = request;
    responder.identify = self.identify;
    if ([_delegate respondsToSelector:(@selector(requestStarted:))]) {
        [_delegate performSelector:@selector(requestStarted:)withObject:responder];
    }
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{

}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL{
    
}

- (void)requestFinished:(ASIHTTPRequest *)request{
    BrokerResponder *responder = [[BrokerResponder alloc] init];
    responder.requestID = [self.networkRequest.requestID integerValue];
    responder.statusCode = 2;
    responder.imgPath = self.filePath;
    responder.request = request;
    responder.identify = self.identify;
    if ([_delegate respondsToSelector:(@selector(requestFinished:))]) {
        [_delegate performSelector:@selector(requestFinished:)withObject:responder];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request{
    BrokerResponder *responder = [[BrokerResponder alloc] init];
    responder.requestID = [self.networkRequest.requestID integerValue];
    responder.statusCode = 3;
//    responder.imgPath = self.filePath;
    responder.request = request;
    responder.identify = self.identify;
    if ([_delegate respondsToSelector:(@selector(requestFailed:))]) {
        [_delegate performSelector:@selector(requestFailed:)withObject:responder];
    }
}

- (void)requestRedirected:(ASIHTTPRequest *)request{
    
}

@end
