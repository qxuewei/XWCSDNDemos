//
//  XWTest.m
//  XWBlogsDemos
//
//  Created by 邱学伟 on 2018/3/1.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "XWTest.h"
#import <objc/runtime.h>

@interface XWTest2 : NSObject
- (void)unrecognized;
@end
@implementation XWTest2
- (void)unrecognized {
    NSLog(@"unrecognized");
}
@end

@implementation XWTest
void myMethod(id self, SEL _cmd) {
    NSLog(@"myMethod 被调用!");
}
/// 第一次
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@" %s",__func__);
    if ([NSStringFromSelector(sel) isEqualToString:@"unrecognized"]) {
        class_addMethod([self class], sel, (IMP)myMethod,"v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

/// 第二次
-(id)forwardingTargetForSelector:(SEL)aSelector {
    NSString *selectorName = NSStringFromSelector(aSelector);
    if ([selectorName isEqualToString:@"unrecognized"]) {
        XWTest2 *myobject = [[XWTest2 alloc] init];
        return myobject;
    }
    return [super forwardingTargetForSelector:aSelector];
}

/// 第三次
-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if([XWTest2 instancesRespondToSelector:aSelector])
        {
            signature = [XWTest2 instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([XWTest2 instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:[[XWTest2 alloc] init]];
    }
}

@end


