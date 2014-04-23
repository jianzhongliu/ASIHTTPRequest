//
//  SampleRequestManager.m
//  TestASI
//
//  Created by jianzhongliu on 4/23/14.
//  Copyright (c) 2014 anjuke. All rights reserved.
//

#import "SampleRequestManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation SampleRequestManager
+(instancetype)shareInsatance {
    static SampleRequestManager *request = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (request == nil) {
            request = [[SampleRequestManager alloc] init];
            
        }
    });
    return request;
}

- (void)dealloc {
//    [request clearDelegatesAndCancel];//request并不retain它们的代理，所以有可能你已经释放了代理，而之后request完成了，这将会引起崩溃。大多数情况下，如果你的代理即将被释放，你一定也希望取消所有request，因为你已经不再关心它们的返回情况了。如此做：
}
- (void)firstRequestForSynchronous {
    NSURL *url = [NSURL URLWithString:@"http://www.dreamingwish.com"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        NSString *response = [request responseString];
        NSLog(@"firstRequestForSynchronous====%@", response);
    }
}
- (void)secondRequestForAsynchronous {
    NSURL *url = [NSURL URLWithString:@"http://www.dreamingwish.com"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];

}
//在平台支持情况下，ASIHTTPRequest1.8以上支持block。
- (void)thirdRequestForBlockRequest {
    NSURL *url = [NSURL URLWithString:@"http://allseeing-i.com"];
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];//注意，声明request时要使用__block修饰符，这是为了告诉block不要retain request，以免出现retain循环，因为request是会retain block的
    [request setCompletionBlock:^{
        // Use when fetching text data
        NSString *responseString = [request responseString];
        
        // Use when fetching binary data
        NSData *responseData = [request responseData];
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
    }];
    [request startAsynchronous];
}

- (void)forthRequestForRequestQueue {
    NSOperationQueue *myQueue = [[NSOperationQueue alloc] init];
    myQueue.maxConcurrentOperationCount = 1;
    
    for (int i = 0; i<20; i ++) {
    NSURL *url = [NSURL URLWithString:@"http://www.dreamingwish.com"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.tag = i;                                        //用tag或者userinfo来区分每个请求。
    [request setDelegate:self];
//    [request setDidFinishSelector:@selector(requestDone:)];
//    [request setDidFailSelector:@selector(requestWentWrong:)];//注意：如果不这定selector，就会调用delegate的方法，
    [myQueue addOperation:request]; //queue is an NSOperationQueue
    }
    
    //当ASINetworkQueue中的一个request失败时，默认情况下，ASINetworkQueue会取消所有其他的request。要禁用这个特性，设置 [queue setShouldCancelAllRequestsOnFailure:NO]。
    //ASINetworkQueues只可以执行ASIHTTPRequest操作，二不可以用于通用操作。试图加入一个不是ASIHTTPRequest的NSOperation将会导致抛出错误。
    
    //取消一个异步请求（无论request是由[request startAsynchronous]开始的还是从你创建的队列中开始的），使用[request cancel]即可。注意同步请求不可以被取消。
    //取消一个请求，会同时取消队列中得所有请求。
    
}
- (void)fifthRequestForPostData {//上传成功：http://pic1.ajkimg.com/display/a260f54640e4a291dcf44b2ffe77f52a/420x315.jpg 上传成功后会返回杀一码，替换中间的杀一码就可以访问了，可以调整图片大小
    
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request addRequestHeader:@"Referer" value:@"http://www.dreamingwish.com/"];//设定request头,签名，请求数据方式等都在头里面
    //通常数据是以’application/x-www-form-urlencoded’格式发送的，如果上传了二进制数据或者文件，那么格式将自动变为‘multipart/form-data’ 文件中的数据是需要时才从磁盘加载，所以只要web server能处理，那么上传大文件是没有问题的。
    NSURL *url = [NSURL URLWithString:@"http://upd1.ajkimg.com/upload"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
//    [request setPostValue:@"Ben" forKey:@"name"];//你可以使用addPostValue方法来发送相同name的多个数据（梦维：服务端会以数组方式呈现）：
//    [request setPostValue:@"Copsey" forKey:@"name"];
    request.delegate = self;
//    [request setUserInfo:@{@"identify": @"sdfsdfsdfsdfsd"}];
    request.tag = 1;
    [request addFile:@"/Users/jianzhongliu/Library/Application Support/iPhone Simulator/7.1/Applications/87233508-A4E7-4529-86F8-8BB9D8A8C0A4/Library/0.jpg" forKey:@"file"];//成功
//    [request setFile:@"/Users/jianzhongliu/Library/Application Support/iPhone Simulator/7.1/Applications/87233508-A4E7-4529-86F8-8BB9D8A8C0A4/Library/0.jpg" forKey:@"file"];//成功
//    [request setFile:@"/Users/jianzhongliu/Library/Application Support/iPhone Simulator/7.1/Applications/87233508-A4E7-4529-86F8-8BB9D8A8C0A4/Library/0.jpg" withFileName:@"myphoto.jpg" andContentType:@"image/jpeg" forKey:@"file"];//数据的mime头是自动判定的，但是如果你想自定义mime头，那么这样：
//    NSData *imageData = [NSData dataWithContentsOfFile:@"/Users/jianzhongliu/Library/Application Support/iPhone Simulator/7.1/Applications/87233508-A4E7-4529-86F8-8BB9D8A8C0A4/Library/0.jpg"];
//    [request setData:imageData withFileName:@"myphoto.jpg" andContentType:@"image/jpeg" forKey:@"file"];//直接上传二进制数据,（成功）
        [request startAsynchronous];
    
    //如果你想发送PUT请求，或者你想自定义POST请求，使用appendPostData: 或者 appendPostDataFromFile:
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request appendPostData:[@"This is my data" dataUsingEncoding:NSUTF8StringEncoding]];
//    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:
//    [request setRequestMethod:@"PUT"];
}

- (void)sixthRequestForDownloadFileSource {//下载成功
    NSURL *url = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=1f120b31d2160924dc25a51be03f34fa/1f178a82b9014a905fec2adaab773912b21bee83.jpg"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
//    request.timeOutSeconds = 30;
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/Library/0.jpg", NSHomeDirectory()]];
    [request startAsynchronous];

    //获取HTTP状态码
    int statusCode = [request responseStatusCode];
    NSString *statusMessage = [request responseStatusMessage];
    
    //读取响应头
    NSString *poweredBy = [[request responseHeaders] objectForKey:@"X-Powered-By"];
    NSString *contentType = [[request responseHeaders] objectForKey:@"Content-Type"];
    
//注意：如果你想处理服务器响应的数据（例如，你想使用流解析器对正在下载的数据流进行处理），你应该实现代理函数 request:didReceiveData:。注意如果你这么做了，ASIHTTPRequest将不会填充responseData到内存，也不会将数据写入文件（downloadDestinationPath ）——你必须自己搞定这两件事（之一）。
    
}

- (void)seventhRequestForDownloadIMGProgress:(UIProgressView *) myProgressIndicator{//进度条失败
    NSURL *url = [NSURL URLWithString:@"http://b.hiphotos.baidu.com/image/w%3D2048/sign=1f120b31d2160924dc25a51be03f34fa/1f178a82b9014a905fec2adaab773912b21bee83.jpg"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    [request setDownloadProgressDelegate:self];
    [request setDownloadDestinationPath:[NSString stringWithFormat:@"%@/Library/0.jpg", NSHomeDirectory()]];
    [request startSynchronous];
}

- (void)eighthRequestForLogin {//?
//    NSURL *url = [NSURL URLWithString:@"http://www.dreamingwish.com/"];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    [request setUseKeychainPersistence:YES];//把凭证放入keychain
//    [request setUseSessionPersistence:YES]; //将凭证放入session这一项是默认的，所以并不必要
//    [request setAuthenticationScheme:(NSString *)kCFHTTPAuthenticationSchemeBasic];
//    [request setShouldPresentCredentialsBeforeChallenge:NO];
//    [request setUsername:@"username"];
//    [request setPassword:@"password"];
//    [request startAsynchronous];
    

}
- (void)nightRequestForResumeDownloadFile{
    NSURL *url = [NSURL URLWithString:
                  @"http://www.dreamingwish.com/wp-content/uploads/2011/10/asihttprequest-auth.png"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    NSString *downloadPath = @"/var/mobile/Applications/38A9446E-C82D-474E-86F2-9C44CFF1A343/Library/asi.png";
    
    //当request完成时，整个文件会被移动到这里
    [request setDownloadDestinationPath:downloadPath];
    
    //这个文件已经被下载了一部分
    [request setTemporaryFileDownloadPath:@"/var/mobile/Applications/38A9446E-C82D-474E-86F2-9C44CFF1A343/Library/asi.png.download"];
    [request setAllowResumeForFileDownloads:YES];//yes表示支持断点续传
    request.delegate = self;
    [request startAsynchronous];
    
    //整个文件将会在这里
    NSString *theContent = [NSString stringWithContentsOfFile:downloadPath];
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    NSLog(@"%d====%@", request.tag, responseString);
    // Use when fetching binary data
    NSData *responseData = [request responseData];
}

- (void)requestStarted:(ASIHTTPRequest *)request {

}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
}

//- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
//
//
//}
//
//- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
//
//    
//}

@end
