//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "People+Category.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testCategory];
}

- (void)testCategory {
    People *people = [[People alloc] init];
    people.name = @"极客学伟";
    people.blog = @"www.qiuxuewei.com";
    NSLog(@"blog : %@",people.blog);
}


@end
