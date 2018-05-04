//
//  ViewController.m
//  RuntimeDemo
//
//  Created by 邱学伟 on 2018/4/27.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "People+Category.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

+ (void)load {
    [super load];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testBlock];
    
//    [self testCategory];
}

- (void)testBlock {
    IMP imp = imp_implementationWithBlock(^(id obj, NSString *str) {
        NSLog(@"testBlock - %@",str);
    });
    class_addMethod(self.class, @selector(testBlock:), imp, "v@:@");
    [self performSelector:@selector(testBlock:) withObject:@"邱学伟!"];
}


- (void)testCategory {
    People *people = [[People alloc] init];
    people.name = @"极客学伟";
    people.blog = @"www.qiuxuewei.com";
    NSLog(@"blog : %@",people.blog);
}


@end
