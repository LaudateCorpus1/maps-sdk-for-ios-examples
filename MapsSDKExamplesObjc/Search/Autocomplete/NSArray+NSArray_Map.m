//
/**
 * Copyright (c) 2020 TomTom N.V. All rights reserved.
 *
 * This software is the proprietary copyright of TomTom N.V. and its subsidiaries and may be used
 * for internal evaluation purposes or commercial use strictly subject to separate licensee
 * agreement between you and TomTom. If you are the licensee, you are only permitted to use
 * this Software in accordance with the terms of your license agreement. If you are not the
 * licensee then you are not authorised to use this software in any manner and should
 * immediately return it to TomTom N.V.
 */

#import "NSArray+NSArray_Map.h"

// inspiration https://medium.com/@weijentu/higher-order-functions-in-objective-c-850f6c90de30

@implementation NSArray (NSArray_Map)

- (NSArray *)map:(id (^)(id obj))block {
    NSMutableArray *mapped = [NSMutableArray array];
    for (id obj in self) {
        id newObj = block(obj);
        if (newObj != NULL) {
            [mapped addObject:newObj];
        }
    }
    return mapped;
}

- (NSArray *)flatMap:(id (^)(id obj))block {
    NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      id _obj = block(obj);
      if ([_obj isKindOfClass:[NSArray class]]) {
          NSArray *_array = [_obj flatMap:block];
          [mutableArray addObjectsFromArray:_array];
          return;
      }
      [mutableArray addObject:_obj];
    }];
    return [mutableArray copy];
}
@end
