//
//  People.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "People.h"
#import <objc/runtime.h>
@interface People () <NSCoding>
@end
@implementation People

// 归档
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int outCount;
        Ivar * ivarList = class_copyIvarList([self class], &outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            Ivar ivar = ivarList[i];
            NSString *key = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}
// 解档
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount;
    Ivar * ivarList = class_copyIvarList([self class], &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        Ivar ivar = ivarList[i];
        NSString *key = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

/// runtime 字典转模型
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [self init]) {
        NSMutableArray <NSString *>*keys = [NSMutableArray array];
        NSMutableArray <NSString *>*attributes = [NSMutableArray array];
        
        unsigned int outCount;
        objc_property_t * propertyList = class_copyPropertyList([self class], &outCount);
        for (unsigned int i = 0; i < outCount; i++) {
            objc_property_t property = propertyList[i];
            const char *name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            [keys addObject:propertyName];
            
            const char *attribute = property_getAttributes(property);
            NSString *attributeName = [NSString stringWithCString:attribute encoding:NSUTF8StringEncoding];
            [attributes addObject:attributeName];
        }
        free(propertyList);
        for (NSString *key in keys) {
            if ([dict valueForKey:key]) {
                [self setValue:[dict valueForKey:key] forKey:key];
            }
        }
    }
    return self;
}

@end
