//
//  NSData+Ext.h
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Ext)

+ (NSData *)dataFromRC4:(NSData *)data key:(NSData *)key;
+ (NSData *)dataFromRC4:(NSData *)data keyString:(NSString *)key;

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

- (NSData *)md5Data;
//4.31新增
- (NSData *)newMd5Data;
- (NSString *)md5Base64;

- (NSString *)hexStringValue;

// Returns range [start, null byte), or (NSNotFound, 0).
- (NSRange) rangeOfNullTerminatedBytesFrom:(int)start;

// Canonical Base32 encoding/decoding.
+ (NSData *) dataWithBase32String:(NSString *)base32;
- (NSString *) base32String;

// COBS is an encoding that eliminates 0x00.
- (NSData *) encodeCOBS;
- (NSData *) decodeCOBS;

// ZLIB
- (NSData *) zlibInflate;
- (NSData *) zlibDeflate;

// GZIP
- (NSData *) gzipInflate;
- (NSData *) gzipDeflate;
@end

#pragma mark - 
@interface NSMutableData (Ext)

- (void)appendBase64String:(NSString *)str;
- (void)rc4TransformWithKey:(NSData *)key;
- (void)rc4TransformWithKeyString:(NSString *)key;

@end