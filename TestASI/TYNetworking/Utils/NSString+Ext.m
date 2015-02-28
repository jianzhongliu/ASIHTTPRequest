//
//  NSString+Ext.m
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#import "NSString+Ext.h"
#import "NSData+Ext.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Ext)

- (int) indexOf:(NSString *)text 
{
    NSRange range = [self rangeOfString:text];
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}

- (int) lastIndexOf:(NSString *)text
{
    NSRange range = [self rangeOfString:text options:NSBackwardsSearch];
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}

- (BOOL) hasString:(NSString *)text
{
    int idx = [self indexOf:text];
    return (idx >= 0);
}

+ (NSString *)stringWithUrlEncodedString:(NSString *)string
{
    return [NSString stringWithUrlEncodedString:string encoding:kCFStringEncodingUTF8];
}

+ (NSString *)stringWithUrlEncodedString:(NSString *)string encoding:(CFStringEncoding)encoding
{
    CFStringRef refSource = CFBridgingRetain(string);
    CFStringRef refEsc = CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`");
    CFStringRef refDest = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, refSource, NULL, refEsc, encoding);
    CFRelease(refSource);
    
    NSString *rst = (NSString*)CFBridgingRelease(refDest);
    if (rst == nil) rst = @"";
	return rst;
}

- (NSString *)urlEncodedString
{
    return [self urlEncodedString:kCFStringEncodingUTF8];
}

- (NSString *)urlEncodedString:(CFStringEncoding)encoding
{
    return [NSString stringWithUrlEncodedString:self encoding:encoding];
}

+ (NSString *)stringWithUrlDecodedString:(NSString *)string
{
    return [NSString stringWithUrlDecodedString:string encoding:kCFStringEncodingUTF8];
}

+ (NSString *)stringWithUrlDecodedString:(NSString *)string encoding:(CFStringEncoding)encoding
{
    CFStringRef refSource = CFBridgingRetain(string);
    CFStringRef refDest = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, refSource, CFSTR(""), encoding);
    CFRelease(refSource);
    
    NSString *rst = (NSString*)CFBridgingRelease(refDest);
    if (rst == nil) rst = @"";
	return rst;
}

- (NSString*)urlDecodedString
{
    return [NSString stringWithUrlDecodedString:self encoding:kCFStringEncodingUTF8];
}

- (NSString*)urlDecodedString:(CFStringEncoding)encoding
{
    return [NSString stringWithUrlDecodedString:self encoding:encoding];
}

- (NSString *)hashStringBase64
{
    if (self.length <= 0) return @"";
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data md5Base64];
}

- (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)MD5String
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(NSMutableString *)stringWithSplit:(NSString *)sp push:(NSString *)push max:(NSInteger)max;
{
    NSMutableString *rst = [[NSMutableString alloc] init];
    
    //添加新信息
    [rst appendString:push];
    
    //现有线路
    int cnt = 1;
    if ([self length] > 0){
        NSArray *arr = [self componentsSeparatedByString:@","];
        for (NSString *str in arr) {
            if (![push isEqualToString:str]){
                [rst appendString:@","];    
                [rst appendString:str]; 
                cnt = cnt + 1;
                if (cnt >= max) break;
            }
        }
    }
    return rst;
}

@end

