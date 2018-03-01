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


#pragma mark -Runtime
/// 交换方法
+ (void)load {
    [super load];
    
    Method originalM = class_getInstanceMethod([self class], @selector(originMethod));
    Method exchangeM = class_getInstanceMethod([self class], @selector(exChangeMethod));
    method_exchangeImplementations(originalM, exchangeM);
    
}

- (void)originMethod {
    NSLog(@"originMethod");
    
}
- (void)exChangeMethod {
    NSLog(@"exChangeMethod");
    
}

/// 创建类
- (void)creatClassMethod {

    Class Person = objc_allocateClassPair([NSObject class], "Person", 0);
    //添加属性
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "_privateName" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty(Person, "name", attrs, 3);
    //添加方法
    class_addMethod(Person, @selector(name), (IMP)nameGetter, "@@:");
    class_addMethod(Person, @selector(setName:), (IMP)nameSetter, "v@:@");
    //注册该类
    objc_registerClassPair(Person);
    
    //获取实例
    id instance = [[Person alloc] init];
    NSLog(@"%@", instance);
    [instance setName:@"hxn"];
    NSLog(@"%@", [instance name]);
}
//get方法
NSString *nameGetter(id self, SEL _cmd) {
    Ivar ivar = class_getInstanceVariable([self class], "_privateName");
    return object_getIvar(self, ivar);
}
//set方法
void nameSetter(id self, SEL _cmd, NSString *newName) {
    Ivar ivar = class_getInstanceVariable([self class], "_privateName");
    id oldName = object_getIvar(self, ivar);
    if (oldName != newName) object_setIvar(self, ivar, [newName copy]);
}


@end


