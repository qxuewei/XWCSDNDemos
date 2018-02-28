//
//  ViewController.m
//  XWBlogsDemos
//
//  Created by 邱学伟 on 2018/2/28.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self testCopy];
}

- (void)testCopy {
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObject:@"mutableArray"];
    NSArray *array = [NSArray arrayWithObject:@"array"];
    id copy_mutableArray = mutableArray.copy;
    id copy_array = array.copy;
    id mutableCopy_mutableArray = mutableArray.mutableCopy;
    id mutableCopy_array = array.mutableCopy;
    NSLog(@"mutableArray:%@ ,内存地址%p -- 指针地址%p",mutableArray,mutableArray,&mutableArray);
    NSLog(@"array:%@ ,内存地址%p -- 指针地址%p",array,array,&array);
    NSLog(@"copy_mutableArray:%@ ,内存地址%p -- 指针地址%p",copy_mutableArray,copy_mutableArray,&copy_mutableArray);
    NSLog(@"copy_array:%@ ,内存地址%p -- 指针地址%p",copy_array,copy_array,&copy_array);
    NSLog(@"mutableCopy_mutableArray:%@ ,内存地址%p -- 指针地址%p",mutableCopy_mutableArray,mutableCopy_mutableArray,&mutableCopy_mutableArray);
    NSLog(@"mutableCopy_array:%@ ,内存地址%p -- 指针地址%p",mutableCopy_array,mutableCopy_array,&mutableCopy_array);
    
}


@end
