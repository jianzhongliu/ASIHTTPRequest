//
//  NSString+Ext.h
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Ext)
- (int) indexOf:(NSString *)text;
- (int) lastIndexOf:(NSString *)text;
- (BOOL) hasString:(NSString *)text;

+ (NSString *)stringWithUrlEncodedString:(NSString *)string;
+ (NSString *)stringWithUrlEncodedString:(NSString *)string encoding:(CFStringEncoding)encoding;
- (NSString *)urlEncodedString;
- (NSString *)urlEncodedString:(CFStringEncoding)encoding;

+ (NSString *)stringWithUrlDecodedString:(NSString *)string;
+ (NSString *)stringWithUrlDecodedString:(NSString *)string encoding:(CFStringEncoding)encoding;
- (NSString*)urlDecodedString;
- (NSString*)urlDecodedString:(CFStringEncoding)encoding;

- (NSString *)hashStringBase64;

- (NSMutableString *)stringWithSplit:(NSString *)sp push:(NSString *)push max:(NSInteger)max;

- (NSString *)md5:(NSString *)str;

- (NSString *)MD5String;

@end

