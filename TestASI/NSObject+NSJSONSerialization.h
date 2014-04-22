//
//  NSObject+NSJSONSerialization.h
//  RTApiProxy
//
//  Created by yan zheng on 13-9-29.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (NSJSONSerialization)

- (NSString *)RTJSONRepresentation;

@end


@interface NSString (NSJSONSerialization)

- (id)JSONValue;

@end