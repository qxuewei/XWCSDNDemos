//
//  ViewController.m
//  XWLockDemo
//
//  Created by qiuxuewei on 2020/12/18.
//  Copyright © 2020 qiuxuewei. All rights reserved.
//

#import "ViewController.h"
// OSSpinLock 需要
#import <libkern/OSAtomic.h>
// os_unfair_lock 需要
#import <os/lock.h>
// pthread_mutex_t 需要
#import <pthread.h>

@interface ViewController () {
    OSSpinLock spinLock;
    os_unfair_lock unfairLock;
    pthread_mutex_t pthread_mutex;
    NSLock *lock;
    dispatch_semaphore_t semaphore_t;
}
@property (nonatomic, strong) NSMutableArray *arrayM;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMethod];
    NSLog(@"start+++++++++++++++++++=");
//    [self testLock];
    [self testDispatch_barrier_syncCase];
    NSLog(@"end----------------------");
}
- (void)dealloc {
    pthread_mutex_destroy(&(pthread_mutex));
}
- (void)initMethod {
    spinLock = OS_SPINLOCK_INIT;
    unfairLock = OS_UNFAIR_LOCK_INIT;
    pthread_mutex_t mutex_t = PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex = mutex_t;
    lock = NSLock.new;
    
    semaphore_t = dispatch_semaphore_create(0);
    dispatch_semaphore_signal(semaphore_t);
}
- (void)testLock {
    for (NSUInteger i = 0; i < 100000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self testDispatch_semaphore_tCase];
        });
    }
}
// OSSpinLock
- (void)testOSSpinLockCase {
    OSSpinLockLock(&spinLock);
    self.arrayM = [NSMutableArray array];
    OSSpinLockUnlock(&spinLock);
}
// os_unfair_lock
- (void)testOs_unfair_lockCase {
    if (!os_unfair_lock_trylock(&(unfairLock))) {
        os_unfair_lock_lock(&(unfairLock));
    }
    self.arrayM = [NSMutableArray array];
    os_unfair_lock_unlock(&(unfairLock));
}
// pthread_mutex
- (void)testPthread_mutexCase {
    pthread_mutex_lock(&(pthread_mutex));
    self.arrayM = [NSMutableArray array];
    pthread_mutex_unlock(&(pthread_mutex));
}
// NSLock
- (void)testNSLockCase {
    [lock lock];
    self.arrayM = [NSMutableArray array];
    [lock unlock];
}
// dispatch_semaphore_t
- (void)testDispatch_semaphore_tCase {
    dispatch_semaphore_wait(semaphore_t, DISPATCH_TIME_FOREVER);
    self.arrayM = [NSMutableArray array];
    dispatch_semaphore_signal(semaphore_t);
}
// dispatch_barrier_sync
- (void)testDispatch_barrier_syncCase {
    dispatch_queue_t queue = dispatch_queue_create("com.qiuxuewei.brrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"任务1 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务2 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务3 -- %@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"任务0 start -- %@",[NSThread currentThread]);
        sleep(5);
        NSLog(@"任务0 end --- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务4 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务5 -- %@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务6 -- %@",[NSThread currentThread]);
    });
}
@end
