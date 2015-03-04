//
//  NSDictionary+Ext.m
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#import "NSDictionary+Ext.h"
@implementation NSDictionary (Ext)

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)json
{
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    return [self dictionaryWithJSONData:data];
}

+ (NSDictionary *)dictionaryWithJSONData:(NSData *)json
{
    NSDictionary *rst = nil;
    NSError *err = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:json options:0 error:&err];
    if ([obj isKindOfClass:[NSDictionary class]]){
        rst = obj;
    }
    return rst;
}

- (NSString *)jsonString
{
    NSString *rst = nil;
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&err];
    if (data.length > 0) rst = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return rst;
}

-(NSString *)stringForKey:(NSString *)key
{
    return [self stringForKey:key def:@""];
}

-(NSString *)stringForKey:(NSString *)key def:(NSString *)def
{
    NSString *rst = [self objectForKey:key];
    
    if (!rst) rst = def;
    return rst;
}


- (int)intForKey:(id)key
{
    return [self intForKey:key defaultValue:0];
}

- (int)intForKey:(id)key defaultValue:(int)def
{
    int rst = def;
    id val = [self objectForKey:key];
    if (val){
        if (![val isKindOfClass:[NSNull class]]) rst = [val intValue];
    }
    return rst;
}

- (double)doubleForKey:(id)key
{
    return [self doubleForKey:key defaultValue:0.0];
}

- (double)doubleForKey:(id)key defaultValue:(double)def
{
    double rst = def;
    id val = [self objectForKey:key];
    if (val){
        if (![val isKindOfClass:[NSNull class]]) rst = [val doubleValue];
    }
    return rst;    
}

-(BOOL)boolForKey:(id)key
{
    return [self boolForKey:key defaultValue:FALSE];
}

-(BOOL)boolForKey:(id)key defaultValue:(BOOL)def
{
    BOOL rst = def;
    id val = [self objectForKey:key];
    if (val){
        if ([val isKindOfClass:[NSNull class]]){
            //Null
            rst = def;
        }else if ([val isKindOfClass:[NSNumber class]]){
            rst = [val boolValue];
        }else if ([val isKindOfClass:[NSString class]]){
            rst = [val boolValue];
        }
    }
    return rst;
}

- (NSDictionary *)dictForKey:(id)key
{
    NSDictionary *rst = nil;
    id val = [self objectForKey:key];
    if (val){
        if ([val isKindOfClass:[NSDictionary class]]) rst = val;
    }
    return rst;
}

- (NSArray *)arrayForKey:(id)key
{
    NSArray *rst = nil;
    id val = [self objectForKey:key];
    if (val){
        if ([val isKindOfClass:[NSArray class]]) rst = val;
    }
    return rst;
}

- (NSArray *)arrayForKeyEx:(id)key
{
    NSArray *rst = nil;
    id val = [self objectForKey:key];
    if (val){
        if ([val isKindOfClass:[NSArray class]]) {
            rst = val;
        }else if ([val isKindOfClass:[NSDictionary class]]) {
            NSDictionary *infos = val;
            rst = infos.allValues;
        }
    }
    return rst;
}

@end

@implementation NSMutableDictionary (Ext)
-(void)setCoderObject:(id<NSCoding>)obj forKey:(id)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
    [self setValue:data forKey:key];
}

-(id)coderObjectForKey:(id)key
{
    id rst = nil;
    NSData *data = [self valueForKey:key];
    if (data.length > 0){
        rst = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return rst;
    //NSData *data = []
}
@end
