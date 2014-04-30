//
//  IMGDowloaderManager.m
//  AnjukeBroker_New
//
//  Created by jianzhongliu on 4/28/14.
//  Copyright (c) 2014 Wu sicong. All rights reserved.
//

#import "IMGDowloaderManager.h"

@implementation IMGDowloaderManager

- (NSOperationQueue *)requestQueue {
    if (_requestQueue == nil) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _requestQueue;
}

- (void)dealloc {
    if (self.requestQueue) {
        [self.requestQueue cancelAllOperations];
        
        self.requestQueue = nil;
    }
}

- (void)cancelAllRequest {
    if (self.requestQueue) {
        [self.requestQueue cancelAllOperations];
        self.requestQueue = nil;
    }
}

- (void)dowloadIMGWithImgURL:(NSString *)url identify:(NSString *) identify successBlock:(void(^)(BrokerResponder *))successBlock fialedBlock:(void(^)(BrokerResponder *))failedBlock{
    self.successBlock = successBlock;
    self.faildBlock = failedBlock;
    IMGDownloaderOperation *requestOperation = [[IMGDownloaderOperation alloc] init];
    requestOperation.requestString = url;
    requestOperation.delegate = self;
    requestOperation.identify = identify;
    requestOperation.filePath = [self componentOfImgPath:url identify:identify];
    [self.requestQueue addOperation:requestOperation];
}

- (NSString *)componentOfImgPath:(NSString *)urlString identify:(NSString *) identfy{
   NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *tempForderArray = [urlString componentsSeparatedByString:@"/"];
    NSString *fileName = [tempForderArray lastObject];
    NSString *fileNameWithoutExt = identfy;
    NSString *fileExtention = [[fileName componentsSeparatedByString:@"."] lastObject];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *forderPath = [libraryPath stringByAppendingPathComponent:@"tempImgForder"];
    NSString *fileNamePath = [forderPath stringByAppendingPathComponent:fileNameWithoutExt];
    NSString *filePath = [fileNamePath stringByAppendingPathExtension:fileExtention];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }else {
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return filePath;
}

- (NSString *)uniqString {
    CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
    NSString *uuidString = [NSString stringWithString:(NSString*)CFBridgingRelease(strRef)];
    return uuidString;
}

- (void)requestStarted:(BrokerResponder *)request {
    self.successBlock(request);
}

- (void)requestFinished:(BrokerResponder *)request {
    self.successBlock(request);
}

-(void)requestFailed:(BrokerResponder *)request {
    self.faildBlock(request);
}

@end
