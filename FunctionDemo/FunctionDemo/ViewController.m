//
//  ViewController.m
//  FunctionDemo
//
//  Created by 邱学伟 on 2018/7/2.
//  Copyright © 2018 邱学伟. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
#define CONCURRENT_TASKS 4
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    dispatch_queue_t q = dispatch_queue_create("com.qiuxuewei.gcd", nil);
    dispatch_semaphore_t sema = dispatch_semaphore_create(CONCURRENT_TASKS);
    for (int i = 0; i < 999; i++) {
        dispatch_async(q, ^{
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
