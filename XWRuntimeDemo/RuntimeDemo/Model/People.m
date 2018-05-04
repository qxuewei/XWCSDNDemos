//
//  People.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "People.h"
#import <objc/runtime.h>

@interface XWPeople : NSObject
- (void)people2log;
- (void)people3log;
@end
@implementation XWPeople
- (void)people2log {
    NSLog(@"people2log");
}

- (void)people3log {
    NSLog(@"people3log");
}
@end

@interface People () <NSCoding> {
}
@property (nonatomic, strong) XWPeople *xw_people;
@end
@implementation People

//// 1 级处理
void functionForMethod (id self, SEL _cmd) {
    NSLog(@"functionForMethod");
}
/// 调用未实现对象方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"methodNull"]) {
        class_addMethod(self.class, sel, (IMP)functionForMethod, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
}
/// 调用未实现类方法
+ (BOOL)resolveClassMethod:(SEL)sel {
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"methodNull"]) {
        //v@:表示返回值和参数，可以在苹果官网查看Type Encoding相关文档 https://developer.apple.com/library/mac/DOCUMENTATION/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        class_addMethod(self.class, sel, (IMP)functionForMethod, "v@:");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

/// 2 级处理
- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selName = NSStringFromSelector(aSelector);
    if ([selName isEqualToString:@"people2log"]) {
        return self.xw_people;
    }
    return [super forwardingTargetForSelector:aSelector];
}
- (XWPeople *)xw_people {
    if(!_xw_people){
        _xw_people = [[XWPeople alloc] init];
    }
    return _xw_people;
}

/// 3 级处理
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([XWPeople instancesRespondToSelector:aSelector]) {
            signature = [XWPeople instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([XWPeople instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self.xw_people];
    }
}

- (void)testMethod {
    NSLog(@"testMethod");
}



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

+ (void)load {
    //    SEL sel = @selector(testMethod);
    //    NSLog(@"People sel = %p",sel);
    
}


@end
