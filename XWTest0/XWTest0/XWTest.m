//
//  XWTest.m
//  XWTest0
//
//  Created by 邱学伟 on 2018/3/1.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWTest.h"

void myMethod(id self, SEL _cmd) {
    NSLog(@"myMethod 被调用!");
}

@implementation XWTest
- (void)foo {
    NSLog(@"对象方法 foo");
}

+ (void)foo {
    NSLog(@"类方法 foo");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@" %s",__func__);

    return YES;
}

//+ (BOOL)resolveClassMethod:(SEL)sel {
//    NSLog(@" %s",__func__);
//    [self foo];
//    return NO;
//}
//
//- (BOOL)respondsToSelector:(SEL)aSelector {
//    NSLog(@" %s",__func__);
//    [self foo];
//    return YES;
//}
//
//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    NSLog(@"%s - aSelector:%s",__func__,aSelector);
//
//    return @selector(foo);
//}
//
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSLog(@" %s",__func__);
//    return [NSMethodSignature methodSignatureForSelector:@selector(foo)];
//}


@end
