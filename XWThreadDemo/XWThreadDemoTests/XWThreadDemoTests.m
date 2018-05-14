//
//  XWThreadDemoTests.m
//  XWThreadDemoTests
//
//  Created by 邱学伟 on 2018/5/14.
//  Copyright © 2018年 邱学伟. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XWThreadDemoTests : XCTestCase

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
