//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2017/2/10.
//  Copyright © 2017年 邱学伟. All rights reserved.
//   runtime 测试

#import "ViewController.h"
#import "Student.h"
#import "NSString_XW.h"
#import "Student_XW.h"

//1.引入Runtime
#import <objc/runtime.h>

@interface ViewController ()
@property (nonatomic, strong) Student *student;
@end

@implementation ViewController
-(Student *)student{
    if(!_student){
        _student = [[Student alloc] init];
    }
    return _student;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *testExtensin = [[NSString alloc] init];
//    testExtensin.height;
    [self.student performSelector:@selector(_playFootball)];
    [self.student performSelector:@selector(_playBasketballInAddress:with:) withObject:@"东单" withObject:@"sb露露"];
    [Student eat];
//    self.student.score
//    self.student.SCORE = @"12";
//    NSLog(@"%@",self.student.SCORE);
}




@end
