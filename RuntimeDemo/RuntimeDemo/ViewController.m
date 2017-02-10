//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2017/2/10.
//  Copyright © 2017年 邱学伟. All rights reserved.
//   runtime 测试

#import "ViewController.h"
#import "Student.h"

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
    [self.student performSelector:@selector(_playFootball)];
    [self.student performSelector:@selector(_playBasketballInAddress:with:) withObject:@"东单" withObject:@"sb露露"];
//    self.student.SCORE = @"12";
//    NSLog(@"%@",self.student.SCORE);
}




@end
