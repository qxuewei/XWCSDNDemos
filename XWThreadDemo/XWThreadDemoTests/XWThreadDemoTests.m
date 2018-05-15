//
//  XWThreadDemoTests.m
//  XWThreadDemoTests
//
//  Created by 邱学伟 on 2018/5/14.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XWThreadDemoTests : XCTestCase
@property (nonatomic, strong) NSMutableArray *testArrayM;
@property (nonatomic, strong) NSMutableDictionary *dictM;
@end

@implementation XWThreadDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testApplyFor {
    NSLog(@" dispatch_apply 循环开启");
    size_t max = 100000;
    dispatch_queue_t queue = dispatch_queue_create([@"dispatch_apply" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(max, queue, ^(size_t i) {
        dispatch_apply(max, queue, ^(size_t j) {
            /// 执行某操作
        });
    });
    NSLog(@" dispatch_apply 循环结束");
}

- (void)testCommonFor {
    NSLog(@"普通for循环开启");
    NSUInteger max = 100000;
    for (NSUInteger i = 0; i < max; i++) {
        for (NSUInteger j = 0; j < max; j++) {
            /// 执行某操作
        }
    }
    NSLog(@"普通for循环结束");
}

- (void)testBarrierSetCount:(NSUInteger)count forKey:(NSString *)key {
    key = [key copy];
    dispatch_queue_t queue = dispatch_queue_create([@"BarrierQueue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(queue, ^{
        if (count == 0) {
            [self.dictM removeObjectForKey:key];
        }else{
            [self.dictM setObject:@(count) forKey:key];
        }
    });
}

- (void)testBarrier {
    dispatch_queue_t queue = dispatch_queue_create([@"BarrierQueue" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    NSMutableArray *arrayM = [NSMutableArray array];
    self.testArrayM = arrayM;
    /// 一个异步线程添加数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (NSUInteger i = 0; i < 100; i++) {
            dispatch_barrier_async(queue, ^{
                [arrayM addObject:[NSString stringWithFormat:@"%zd",i]];
            });
        }
    });
    /// 一个异步线程删除数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self removeMethod];
    });
}
- (void)removeMethod {
    for (NSUInteger i = 1; i < 50; i++) {
        if (self.testArrayM.count > i) {
            [self.testArrayM removeObject:[NSString stringWithFormat:@"%zd",i]];
        }
    }
    NSLog(@"%@",self.testArrayM);
}



- (void)testNSOperationCancel {
    //只能取消所有队列的里面的操作，正在执行的无法取消
    //取消操作并不会影响队列的挂起状态
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue cancelAllOperations];
    NSLog(@"取消队列里所有的操作");
    //取消队列的挂起状态
    //（只要是取消了队列的操作，我们就把队列处于不挂起状态,以便于后续的开始）
    queue.suspended = NO;
}

- (void)testNSOperationSuspended {
    //判断操作的数量，当前队列里面是不是有操作？
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    if (queue.operationCount == 0) {
        NSLog(@"当前队列没有操作");
        return;
    }
    
    queue.suspended = !queue.isSuspended;
    if (queue.suspended) {
        NSLog(@"暂停");
        
    }else{
        NSLog(@"继续");
    }
}

- (void)testNSOperationDepend {
    /// 定义三个异步操作
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        sleep(1);
        NSLog(@"operation1 - 当前线程:%@",[NSThread currentThread]);
    }];
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        sleep(5);
        NSLog(@"operation2 - 当前线程:%@",[NSThread currentThread]);
    }];
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        sleep(3);
        NSLog(@"operation3 - 当前线程:%@",[NSThread currentThread]);
    }];
    /// 定义主线程更新UI操作
    NSBlockOperation *operationMain = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operationMain - 更新UI - 当前线程:%@",[NSThread currentThread]);
    }];
    
    /// 添加依赖
    [operation1 addDependency:operation3];
    [operation1 addDependency:operation2];
    [operationMain addDependency:operation3];
    
    /// 异步线程添加异步队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:@[operation1,operation2,operation3] waitUntilFinished:YES];
    
    /// 刷新UI添加主线程队列
    [[NSOperationQueue mainQueue] addOperation:operationMain];
}

- (void)testNSOperation3 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSLog(@"异步执行");
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"回到主线程中执行!");
        }];
    }];
}

- (void)testNSOperation2 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSLog(@"异步执行");
    }];
}

- (void)testNSOperation1 {
    NSLog(@"开始");
    /// 创建操作队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i = 0; i < 10; i++) {
        /// 异步操作
        NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"线程:%@,  index: %d",[NSThread currentThread],i);
        }];
        /// 添加到队列中自动异步执行
        [queue addOperation:blockOperation];
    }
    NSLog(@"结束");
}

- (void)testNSOperation {
    NSInvocationOperation *operation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadMethod1:) object:@"url"];
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    [queue1 addOperation:operation1];
}
- (void)downloadMethod1:(id)obj {
    NSLog(@"object: %@ ++ 当前线程: %@",obj,[NSThread currentThread]);
}



- (void)testTongxin {
    dispatch_after(3.0, dispatch_get_main_queue(), ^{
       /// 延时3秒执行的操作!
    });
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}

- (void)testSemaphone {
    dispatch_semaphore_t semaphore_t = dispatch_semaphore_create(1);
    /// 线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /// 进入等待状态!
        dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
        sleep(7);
        dispatch_semaphore_signal(semaphore_t);
    });
}

- (void)testNSLock {
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    // 需要锁定的代码
    [lock unlock];
}

- (void)testNSThread {
    /// 获取当前线程
    NSThread *currentThread = [NSThread currentThread];
    
    /// 创建需要自己启动的线程
    NSThread *creatThread = [[NSThread alloc] initWithTarget:self selector:@selector(runMethod) object:nil];
    [creatThread start];

    /// 创建自动启动的线程
    [NSThread detachNewThreadSelector:@selector(runMethod2) toTarget:self withObject:nil];
}
- (void)runMethod {
    NSLog(@"runMethod ++ %@",[NSThread currentThread]);
}
- (void)runMethod2 {
    NSLog(@"runMethod2 ++ %@",[NSThread currentThread]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
