//
//  NSDictionary+Ext.h
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Ext)

- (NSString *)stringForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key def:(NSString *)def;

- (int)intForKey:(id)key;
- (int)intForKey:(id)key defaultValue:(int)def;

- (double)doubleForKey:(id)key;
- (double)doubleForKey:(id)key defaultValue:(double)def;

- (BOOL)boolForKey:(id)key;
- (BOOL)boolForKey:(id)key defaultValue:(BOOL)def;

- (NSDictionary *)dictForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSArray *)arrayForKeyEx:(id)key;
- (NSString *)jsonString;

+ (NSDictionary *)dictionaryWithJSONString:(NSString *)json;
+ (NSDictionary *)dictionaryWithJSONData:(NSData *)json;

@end

@interface NSMutableDictionary (Ext)
- (void)setCoderObject:(id<NSCoding>)obj forKey:(id)key;
- (id)coderObjectForKey:(id)key;
@end
