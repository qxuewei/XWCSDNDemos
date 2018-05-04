//
//  ViewController+Method.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/5/4.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController+Method.h"
#import <objc/runtime.h>

@implementation ViewController (Method)
+ (void)load {
    [super load];
    [self exchangeMethod];
}



/// runtime 交换方法
+ (void)exchangeMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originSel = @selector(viewWillAppear:);
        SEL swizzledSel = @selector(xw_viewWillAppear:);
        
        Method originMethod = class_getInstanceMethod(class, originSel);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSel);
        
        //先尝试給源方法添加实现，这里是为了避免源方法没有实现的情况
        BOOL isAddMethod = class_addMethod(class, originSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (isAddMethod) {
            class_replaceMethod(class, swizzledSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
        }else{
            method_exchangeImplementations(originMethod, swizzledMethod);
        }
    });
}
- (void)xw_viewWillAppear:(BOOL)animation {
    [self xw_viewWillAppear:animation];
}
@end
