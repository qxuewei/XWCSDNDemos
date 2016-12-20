//
//  ViewController.m
//  StatusBarDemo
//
//  Created by 邱学伟 on 2016/12/20.
//  Copyright © 2016年 邱学伟. All rights reserved.
//  http://blog.csdn.net/qxuewei/article/details/53763653

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self setStatusBarBackgroundColor:[UIColor greenColor]];
}
//设置状态栏背景颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
//状态栏文字颜色  此方法直接添加在需要更改的控制器上即可,无需调用
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
