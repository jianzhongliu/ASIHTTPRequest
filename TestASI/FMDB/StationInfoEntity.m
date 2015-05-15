//
//  StationInfoEnitty.m
//  ticket99
//
//  Created by Ctrip-zxl on 14-11-12.
//  Copyright (c) 2014年 xuzhq. All rights reserved.
//

#import "StationInfoEntity.h"
@implementation StationInfoEntity

@end

@implementation StationItemInfoEntity
-(void)updateEntityWithDict:(NSDictionary *)dict
{
    if (dict){
        self.stationId = [[dict objectForKey:@"stationId"] integerValue];
        self.stationName = [self stringWithUrlDecodedString:[dict objectForKey:@"stationName"] encoding:kCFStringEncodingUTF8];
        self.pinYin = [self stringWithUrlDecodedString:[dict objectForKey:@"pinYin"] encoding:kCFStringEncodingUTF8];
        self.shortPinYin =[self stringWithUrlDecodedString:[dict objectForKey:@"shortPinYin"] encoding:kCFStringEncodingUTF8];
        
        self.teleCode = [self stringWithUrlDecodedString:[dict objectForKey:@"teleCode"] encoding:kCFStringEncodingUTF8];
        
        self.cityName = [self stringWithUrlDecodedString:[dict objectForKey:@"cityName"] encoding:kCFStringEncodingUTF8];
        
        }
}


- (NSString *)stringWithUrlDecodedString:(NSString *)string encoding:(CFStringEncoding)encoding
{
    CFStringRef refSource = CFBridgingRetain(string);
    CFStringRef refDest = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, refSource, CFSTR(""), encoding);
    CFRelease(refSource);
    
    NSString *rst = (NSString*)CFBridgingRelease(refDest);
    if (rst == nil) rst = @"";
    return rst;
}
@end