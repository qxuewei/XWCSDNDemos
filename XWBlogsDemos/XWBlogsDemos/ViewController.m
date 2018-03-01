//
//  ViewController.m
//  XWBlogsDemos
//
//  Created by 邱学伟 on 2018/2/28.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import "ViewController.h"
#import "XWTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testCopy];
//    [self GDC_Semaphore_Demo];
//    [self semaphoreDemo2];
    
    XWTest *test = [[XWTest alloc] init];
    [test creatClassMethod];
}

- (void)GDC_Semaphore_Demo {
    /// 创建一个信号
//    dispatch_semaphore_create(<#long value#>)
    /// 创建计数初始值为1的信号量对象
    dispatch_semaphore_t _semaphore = dispatch_semaphore_create(1);
    
   
    /// 等待信号
//    dispatch_semaphore_wait(<#dispatch_semaphore_t  _Nonnull dsema#>, <#dispatch_time_t timeout#>)
    
    long waitResult = dispatch_semaphore_wait(_semaphore, 3.0);
    if (waitResult == 0) {
        //说明semaphore的值大于等于1，或者在timeout指定时间之内，该函数所处的线程被成功唤醒（比如通过dispatch_semaphore_signal将线程唤醒）。
        NSLog(@"可安全地执行需要进行排他控制的处理。该处理结束后通过dispatch_semaphore_signal 函数将Dispatch Semaphore 的计数值加1");
    }else{
        //说明semaphore的值等于0，此时timeout指定时间内该函数所处的线程处于阻塞。
        //另外，dispatch_semaphore_wait 函数的返回值也dispatch_group_wait 函数相同,可以通过返回值可以进行分支处理。
        NSLog(@"说明semaphore的值等于0，此时timeout指定时间内该函数所处的线程处于阻塞");
    }
    
    /// 发送一个信号
    //    dispatch_semaphore_signal(<#dispatch_semaphore_t  _Nonnull dsema#>)
    //当返回值为0时：表示当前并没有线程等待其处理的信号量，其处理的信号量的值加1即可。
    //当返回值不为0时：表示其当前有（一个或多个线程）等待其处理的信号量，并且该函数唤醒了一个“等待的线    程”（当线程有优先级时，唤醒优先级最高的线程；否则随机唤醒）。
}

- (void)semaphoreDemo1 {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    for (int i = 0; i < 100; i++) {
        //// 由于是异步执行的，所以每次循环Block里面的dispatch_semaphore_signal根本还没有执行就会执行dispatch_semaphore_wait，从而semaphore-1.当循环10此后，semaphore等于0，则会阻塞线程，直到执行了Block的dispatch_semaphore_signal 才会继续执行
        NSLog(@"i %zd",i);
        /// 执行十次之后阻塞当前线程
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)semaphoreDemo2 {
    dispatch_semaphore_t goOnSemaphore = dispatch_semaphore_create(0);
    NSLog(@"ready");
    [self network:^(id result) {
        NSLog(@"net return:%@",result);
        dispatch_semaphore_signal(goOnSemaphore);
    }];
    dispatch_semaphore_wait(goOnSemaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"go on");
}
- (void)network:(void(^)(id result))block {
    sleep(2.0);
    block(@(arc4random_uniform(2)));
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
