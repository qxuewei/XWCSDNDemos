//
//  AppDelegate.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2017/2/10.
//  Copyright © 2017年 邱学伟. All rights reserved.
//

#import "AppDelegate.h"
#import "Student.h"
#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self addNewMethod];
//    [self printProperty];
    [self addProperty];
    return YES;
}


#pragma mark - runtime
-(void)addProperty{
    Class Test= objc_allocateClassPair([Student class], "StudentTest", 0);
    char *texPosEncoding = @encode(NSString);
    NSUInteger textPosSize, textPosAlign;
    NSGetSizeAndAlignment(texPosEncoding, &textPosSize, &textPosAlign);
    class_addIvar([Student class], "SCORE", textPosSize, textPosAlign, texPosEncoding);
//    class_addIvar([Student class], "score", -1, sizeof(value_type), <#const char *types#>)
    objc_registerClassPair(Test);
}

-(void)printProperty{
    unsigned int outCount = 0;
    Ivar *ivarList = class_copyIvarList([Student class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivarList[i];
        const char *name = ivar_getName(ivar);
        NSString *nameStr = [NSString stringWithUTF8String:name];
        NSLog(@"%@",nameStr);
    }
}

//添加新方法
-(void)addNewMethod{
    class_addMethod([Student class], @selector(_playFootball), class_getMethodImplementation([AppDelegate class], @selector(playFootball)), "v@:");
    class_addMethod([Student class], @selector(_playBasketballInAddress:with:), class_getMethodImplementation([AppDelegate class], @selector(playBasketballInAddress:with:)), "v@:@@");
}
-(void)playBasketballInAddress:(NSString *)address with:(NSString *)firendName{
    NSLog(@"和 %@ 在 %@ 打篮球",firendName,address);
}
-(void)playFootball{
    NSLog(@"在踢足球!");
}


@end
