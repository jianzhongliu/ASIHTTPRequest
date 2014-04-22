//
//  NSObject+NSJSONSerialization.m
//  RTApiProxy
//
//  Created by yan zheng on 13-9-29.
//
//

#import "NSObject+NSJSONSerialization.h"

@implementation NSObject (NSJSONSerialization)

- (NSString *)RTJSONRepresentation {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        NSLog(@"RTJSONRepresentation error: %@", error);
        return @"";
    }
    
    NSString* jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

@end

@implementation NSString (NSJSONSerialization)

- (id)JSONValue {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!jsonData) {
        NSLog(@"JSONValue error: %@", error);
        return nil;
    }
    
    return jsonObject;
}

@end